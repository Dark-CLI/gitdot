#!/usr/bin/env bash
# Gallery-style wallpaper picker using swayimg --gallery.
# Bound to SUPER + F12 alongside the existing rofi-based SUPER + W.
# Enter applies the selected wallpaper via swww; Escape cancels.

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SELECTED_FILE="/tmp/hypr-wallpaper-selected"
LUA_SCRIPT="/tmp/hypr-wallpaper-picker.lua"
LIST_FILE="/tmp/hypr-wallpaper-list"
# Persistent across sessions: the last-applied wallpaper path. We re-position
# the gallery cursor to it on next open.
LAST_FILE="$HOME/.cache/hypr-wallpaper-last"
mkdir -p "$(dirname "$LAST_FILE")"

# Build the explicit file list. swayimg's --execute happens AFTER the image
# list is loaded, so its enable_recursive() can't help — we have to pass
# every image explicitly.
# WPF_LIST lets a relaunch (e.g. from "/" search) substitute a filtered list
# without us regenerating it from scratch.
if [ -n "${WPF_LIST:-}" ] && [ -s "$WPF_LIST" ]; then
  cp "$WPF_LIST" "$LIST_FILE"
else
  find -L "$WALLPAPER_DIR" -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
    2>/dev/null | sort -f > "$LIST_FILE"
  # Cache the full list so "/" search can grep against it.
  cp "$LIST_FILE" "$HOME/.cache/hypr-wallpaper-list-cache"
fi

# Single instance: focus existing picker if one is already open.
EXISTING=$(hyprctl clients -j 2>/dev/null | jq -r '.[] | select(.class == "HyprWallpaperPicker") | .address' | head -1)
if [ -n "$EXISTING" ]; then
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$EXISTING\" })" >/dev/null 2>&1
  exit 0
fi

# Calculate window size based on focused monitor
read -r MON_W MON_H < <(hyprctl monitors -j 2>/dev/null | \
  jq -r '.[] | select(.focused == true) | "\(.width) \(.height)"')
[ -z "$MON_W" ] && MON_W=2560
[ -z "$MON_H" ] && MON_H=1440
W=$((MON_W * 54 / 100))
H=$((MON_H * 67 / 100))

# Build the swayimg Lua bootstrap. On Enter, write the selected image's
# path to a sentinel file then exit. On Escape, just exit.
cat > "$LUA_SCRIPT" <<'LUA'
swayimg.set_mode("gallery")
swayimg.imagelist.enable_recursive(true)

-- Position memory is handled at the shell level by passing the last-picked
-- file as a positional argument before --from-file. swayimg starts the
-- gallery cursor on that file.

-- Gallery look — denser grid (original pre-tuning size)
swayimg.gallery.set_thumb_size(220)
swayimg.gallery.set_padding_size(8)
swayimg.gallery.set_border_size(4)
swayimg.gallery.set_selected_scale(1.10)
swayimg.gallery.set_window_color(0xff1a1a1a)
swayimg.gallery.set_selected_color(0xff404040)
swayimg.gallery.set_unselected_color(0xff202020)

-- Speed tuning:
--   pstore enables an on-disk thumbnail cache (~/.cache/swayimg) so the
--   gallery is instant on the second open. First open still has to decode
--   everything once.
--   limit_cache keeps more in RAM during a session so scrolling stays smooth.
--   enable_preload lets swayimg decode off-screen tiles during idle frames
--   so they're ready as soon as you scroll to them.
swayimg.gallery.enable_pstore(true)
swayimg.gallery.limit_cache(400)
swayimg.gallery.enable_preload(true)

-- On-screen hints rendered as a slim status bar at the bottom of the
-- window. swayimg only anchors text to corners, so we collapse all hints
-- into one row and give it a dark translucent background so it reads
-- like a footer bar.
swayimg.text.set_timeout(0)
swayimg.text.set_status_timeout(0)
-- No on-image text overlays — the window title is the status line. This
-- way the gallery is uncluttered and no thumbnails are partially hidden
-- behind opaque text bars. SUPER+F1 covers the keybind reference.
swayimg.gallery.set_text("topleft",     { "" })
swayimg.gallery.set_text("topright",    { "" })
swayimg.gallery.set_text("bottomleft",  { "" })
swayimg.gallery.set_text("bottomright", { "" })

-- Viewer mode: clean too. "auto" makes swayimg fill the empty space around
-- the image with a blurred extension/mirror of the image itself — the look
-- the user liked from slideshow mode.
swayimg.viewer.set_window_background("auto")
swayimg.viewer.set_default_scale("optimal")
swayimg.viewer.set_text("topleft",     { "" })
swayimg.viewer.set_text("topright",    { "" })
swayimg.viewer.set_text("bottomleft",  { "" })
swayimg.viewer.set_text("bottomright", { "" })

-- Helper: extract just the basename from a full path.
local function basename(p)
  return p:match("([^/]+)$") or p
end

-- Viewer mode: simple title with the filename + a hint.
swayimg.viewer.on_image_change(function()
  local img = swayimg.viewer.get_image()
  if img then swayimg.set_title(basename(img.path) .. "  •  preview") end
end)

-- ============================================================
-- Inline vim-style "/" search (live filtering as you type)
-- ============================================================
-- swayimg has no input field API but it does have imagelist.add/remove,
-- so we simulate vim's `/`: each keystroke incrementally updates the
-- imagelist to contain only paths matching the buffer. Backspace shrinks
-- the buffer and re-adds removed paths. Enter locks in the filter and
-- returns to normal navigation; Escape restores the full list.

local search_active = false
local search_buf = ""

-- Snapshot of the original full list. Captured in on_initialized so we
-- can later restore it on Esc.
local all_paths = {}
swayimg.on_initialized(function()
  for _, e in ipairs(swayimg.imagelist.get()) do
    table.insert(all_paths, e.path)
  end
end)

local function render_bar()
  -- Title-only mode: re-derive the title from current state.
  if search_active then
    swayimg.set_title("/" .. search_buf .. "_  •  Wallpaper Picker")
  else
    local img = swayimg.gallery.get_image()
    local name = "Wallpaper Picker"
    if img then name = (img.path:match("([^/]+)$") or img.path) end
    swayimg.set_title(name .. "  •  " .. swayimg.imagelist.size() .. " wallpapers")
  end
end

-- Update the title every time the focused thumbnail changes.
swayimg.gallery.on_image_change(render_bar)

-- Fuzzy match: returns true if every char of `needle` appears in `hay` in
-- order (not necessarily contiguous). Same idea as fzf's basic matching.
-- Example: "ctp" matches "Catppuccin Latte" (c-a-t-p-p-...).
local function fuzzy_match(hay, needle)
  if needle == "" then return true end
  local hi, ni = 1, 1
  while hi <= #hay and ni <= #needle do
    if hay:byte(hi) == needle:byte(ni) then
      ni = ni + 1
    end
    hi = hi + 1
  end
  return ni > #needle
end

-- Recompute the visible imagelist from all_paths filtered by search_buf.
-- Critical: never let the imagelist become empty. swayimg treats an empty
-- list as "nothing to display" and quits the window. If nothing matches we
-- just leave the previous filter alone (the user sees they typed a char
-- that has no matches and can Backspace).
local function apply_filter()
  local needle = search_buf:lower()
  local desired = {}
  for _, p in ipairs(all_paths) do
    if fuzzy_match(p:lower(), needle) then
      desired[p] = true
    end
  end
  -- Bail without changing anything if the new filter would empty the list.
  if next(desired) == nil then return end
  local visible = {}
  for _, e in ipairs(swayimg.imagelist.get()) do visible[e.path] = true end
  for _, p in ipairs(all_paths) do
    if desired[p] and not visible[p] then
      swayimg.imagelist.add(p)
    elseif not desired[p] and visible[p] then
      swayimg.imagelist.remove(p)
    end
  end
end

local function start_search()
  search_active = true
  search_buf = ""
  render_bar()
end

local function cancel_search()
  search_active = false
  search_buf = ""
  render_bar()
  apply_filter()  -- empty buffer → restores full list
end

local function lock_in_search()
  -- Enter on / search: leave the filter applied, return to normal nav.
  search_active = false
  render_bar()
end

local function append(ch)
  search_buf = search_buf .. ch
  render_bar()
  apply_filter()
  -- Reset the gallery cursor to the first match so the user always sees
  -- the top of the filtered results, not a random middle scroll position.
  swayimg.gallery.switch_image("first")
end

local function backspace()
  if #search_buf == 0 then return end
  search_buf = search_buf:sub(1, -2)
  render_bar()
  apply_filter()
  swayimg.gallery.switch_image("first")
end

-- ============================================================
-- Gallery key bindings
-- ============================================================
swayimg.gallery.on_key("Return", function()
  if search_active then lock_in_search(); return end
  local img = swayimg.gallery.get_image()
  local f = io.open("/tmp/hypr-wallpaper-selected", "w")
  if f then f:write(img.path); f:close() end
  -- Write the position-memory file immediately so re-opening the picker
  -- right after Enter (before wallust/refresh finish) lands on the new
  -- pick, not the previous one.
  local last = io.open(os.getenv("HOME") .. "/.cache/hypr-wallpaper-last", "w")
  if last then last:write(img.path); last:close() end
  swayimg.exit()
end)

swayimg.gallery.on_key("Escape", function()
  if search_active then cancel_search(); return end
  swayimg.exit()
end)

swayimg.gallery.on_key("BackSpace", function()
  if search_active then backspace() end
end)

swayimg.gallery.on_key("slash", function() start_search() end)

-- Enter preview (viewer) when not searching.
swayimg.gallery.on_key("space", function()
  if search_active then append(" "); return end
  swayimg.set_mode("viewer")
end)

-- Navigation: arrows always navigate; hjkl navigate only when not searching.
swayimg.gallery.on_key("Left",  function() swayimg.gallery.switch_image("left") end)
swayimg.gallery.on_key("Down",  function() swayimg.gallery.switch_image("down") end)
swayimg.gallery.on_key("Up",    function() swayimg.gallery.switch_image("up") end)
swayimg.gallery.on_key("Right", function() swayimg.gallery.switch_image("right") end)
swayimg.gallery.on_key("Home",  function() swayimg.gallery.switch_image("first") end)
swayimg.gallery.on_key("End",   function() swayimg.gallery.switch_image("last") end)

-- Letters: navigation when not searching (only hjkl), otherwise append.
local function letter_handler(ch, navfn)
  return function()
    if search_active then append(ch); return end
    if navfn then navfn() end
  end
end

swayimg.gallery.on_key("h", letter_handler("h", function() swayimg.gallery.switch_image("left") end))
swayimg.gallery.on_key("j", letter_handler("j", function() swayimg.gallery.switch_image("down") end))
swayimg.gallery.on_key("k", letter_handler("k", function() swayimg.gallery.switch_image("up") end))
swayimg.gallery.on_key("l", letter_handler("l", function() swayimg.gallery.switch_image("right") end))

-- All other a-z keys: only matter while searching.
-- swayimg's key names are case-insensitive, so "a" and "A" are the same
-- binding — don't re-register the uppercase form (it would shadow lowercase).
-- For real shift-letter typing, use the explicit "Shift-x" modifier form.
for c in ("abcdefgimnopqrstuvwxyz"):gmatch(".") do
  swayimg.gallery.on_key(c, letter_handler(c, nil))
  swayimg.gallery.on_key("Shift-" .. c, letter_handler(c:upper(), nil))
end
-- Also wire Shift on hjkl so they type when searching (and don't navigate).
swayimg.gallery.on_key("Shift-h", letter_handler("H", nil))
swayimg.gallery.on_key("Shift-j", letter_handler("J", nil))
swayimg.gallery.on_key("Shift-k", letter_handler("K", nil))
swayimg.gallery.on_key("Shift-l", letter_handler("L", nil))
-- Digits.
for c in ("0123456789"):gmatch(".") do
  swayimg.gallery.on_key(c, letter_handler(c, nil))
end
-- Common punctuation in filenames (must use X11 keysym names, not literal chars).
swayimg.gallery.on_key("period",     letter_handler(".", nil))
swayimg.gallery.on_key("underscore", letter_handler("_", nil))
swayimg.gallery.on_key("Shift-minus", letter_handler("_", nil))  -- _ on US layout

-- minus / equal act as thumb-size zoom OUT / IN when not in search,
-- and append "-" / "=" when searching. (swayimg --config replaces the
-- default init.lua so we have to wire zoom ourselves.)
swayimg.gallery.on_key("minus", function()
  if search_active then append("-"); return end
  local s = swayimg.gallery.get_thumb_size()
  swayimg.gallery.set_thumb_size(math.max(80, s - 30))
end)
swayimg.gallery.on_key("equal", function()
  if search_active then append("="); return end
  local s = swayimg.gallery.get_thumb_size()
  swayimg.gallery.set_thumb_size(math.min(500, s + 30))
end)
swayimg.gallery.on_key("Shift-equal", function()  -- "+" on US layout
  if search_active then append("+"); return end
  local s = swayimg.gallery.get_thumb_size()
  swayimg.gallery.set_thumb_size(math.min(500, s + 30))
end)

-- ============================================================
-- Viewer key bindings (fullscreen-ish single image preview)
-- ============================================================
-- Space or Escape go back to the gallery
swayimg.viewer.on_key("space",  function() swayimg.set_mode("gallery") end)
swayimg.viewer.on_key("Escape", function() swayimg.set_mode("gallery") end)

-- Enter from the viewer applies the wallpaper
swayimg.viewer.on_key("Return", function()
  local img = swayimg.viewer.get_image()
  local f = io.open("/tmp/hypr-wallpaper-selected", "w")
  if f then f:write(img.path); f:close() end
  local last = io.open(os.getenv("HOME") .. "/.cache/hypr-wallpaper-last", "w")
  if last then last:write(img.path); last:close() end
  swayimg.exit()
end)

-- Navigate next/prev image in viewer mode
swayimg.viewer.on_key("h",     function() swayimg.viewer.switch_image("prev") end)
swayimg.viewer.on_key("l",     function() swayimg.viewer.switch_image("next") end)
swayimg.viewer.on_key("Left",  function() swayimg.viewer.switch_image("prev") end)
swayimg.viewer.on_key("Right", function() swayimg.viewer.switch_image("next") end)

LUA

# Clear stale state from any previous run.
rm -f "$SELECTED_FILE" /tmp/hypr-wallpaper-search-query

# Background watcher that applies the wallpaper once swayimg exits.
# Has to wait for the window to APPEAR first (otherwise the "wait for it to
# disappear" loop exits instantly since nothing is open yet).
(
  # Wait up to 5s for the picker window to show up.
  for _ in $(seq 1 50); do
    if hyprctl clients -j 2>/dev/null | jq -e '.[] | select(.class == "HyprWallpaperPicker")' >/dev/null 2>&1; then
      break
    fi
    sleep 0.1
  done
  # Now wait for it to close.
  while hyprctl clients -j 2>/dev/null | jq -e '.[] | select(.class == "HyprWallpaperPicker")' >/dev/null 2>&1; do
    sleep 0.3
  done
  # Apply if the user pressed Enter.
  if [ -s "$SELECTED_FILE" ]; then
    sel=$(cat "$SELECTED_FILE")
    pgrep -x swww-daemon >/dev/null || (swww-daemon --format xrgb & sleep 0.5)
    monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | .name')
    swww img -o "$monitor" "$sel" \
      --transition-type=center \
      --transition-duration=0.6 \
      --transition-fps=60

    # Regenerate color palettes from the new wallpaper, then restart
    # waybar/rofi/swaync so they pick up the new colors.
    # (Position-memory file was already written from the Lua handler the
    # instant Enter was pressed, so this slow chain doesn't block it.)
    "$HOME/.config/hypr/scripts/WallustSwww.sh" "$sel" 2>/dev/null || true
    "$HOME/.config/hypr/scripts/Refresh.sh" 2>/dev/null || true
  fi
) &
disown

# --config loads our Lua as the swayimg config (replaces init.lua role).
# Note: --execute takes inline Lua code, not a file path — wrong for us.
# --from-file passes every image path explicitly so we don't depend on
# swayimg's directory-loading behavior.
# Position memory: if a previous selection exists AND the file still
# exists, pass it as a positional arg so the gallery cursor starts there.
LAST_ARG=""
if [ -s "$LAST_FILE" ]; then
  last=$(cat "$LAST_FILE")
  if [ -f "$last" ]; then
    LAST_ARG=" '$last'"
  fi
fi

hyprctl dispatch \
  "hl.dsp.exec_cmd(\"swayimg --gallery --appid=HyprWallpaperPicker --config=$LUA_SCRIPT --from-file=$LIST_FILE$LAST_ARG\", { float = true, size = \"$W $H\" })" \
  >/dev/null 2>&1

# Wait for window to spawn, then center it using Hyprland's built-in center function
sleep 0.05
hyprctl dispatch "hl.dsp.window.center({ respect_reserved = true })" >/dev/null 2>&1
