#!/usr/bin/env bash
# Gallery-style wallpaper picker using swayimg --gallery.
# Bound to SUPER + F12 alongside the existing rofi-based SUPER + W.
# Enter applies the selected wallpaper via swww; Escape cancels.

WALLPAPER_DIR="$HOME/Pictures/wallpapers"
SELECTED_FILE="/tmp/hypr-wallpaper-selected"
LUA_SCRIPT="/tmp/hypr-wallpaper-picker.lua"
LIST_FILE="/tmp/hypr-wallpaper-list"

# Build the explicit file list. swayimg's --execute happens AFTER the image
# list is loaded, so its enable_recursive() can't help — we have to pass
# every image explicitly.
find -L "$WALLPAPER_DIR" -type f \
  \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) \
  2>/dev/null | sort -f > "$LIST_FILE"

# Single instance: focus existing picker if one is already open.
EXISTING=$(hyprctl clients -j 2>/dev/null | jq -r '.[] | select(.class == "HyprWallpaperPicker") | .address' | head -1)
if [ -n "$EXISTING" ]; then
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$EXISTING\" })" >/dev/null 2>&1
  exit 0
fi

# Center on focused monitor at 54% x 67% size.
read -r MON_X MON_Y MON_W MON_H < <(hyprctl monitors -j 2>/dev/null | \
  jq -r '.[] | select(.focused == true) | "\(.x) \(.y) \(.width) \(.height)"')
[ -z "$MON_W" ] && MON_W=2560
[ -z "$MON_H" ] && MON_H=1440
[ -z "$MON_X" ] && MON_X=0
[ -z "$MON_Y" ] && MON_Y=0
W=$((MON_W * 54 / 100))
H=$((MON_H * 67 / 100))
X=$((MON_X + (MON_W - W) / 2))
Y=$((MON_Y + (MON_H - H) / 2))

# Build the swayimg Lua bootstrap. On Enter, write the selected image's
# path to a sentinel file then exit. On Escape, just exit.
cat > "$LUA_SCRIPT" <<'LUA'
swayimg.set_mode("gallery")
swayimg.imagelist.enable_recursive(true)

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
swayimg.text.set_size(16)
swayimg.text.set_padding(8)
swayimg.text.set_foreground(0xffdddddd)
swayimg.text.set_background(0xcc101010)
swayimg.text.set_shadow(0x00000000)

swayimg.gallery.set_text("topleft", { "{name}   ·   {list.index}/{list.total}" })
swayimg.gallery.set_text("bottomleft", {
  "  hjkl/↑↓←→ navigate   ·   Space preview   ·   Enter apply   ·   Esc cancel  "
})

-- Viewer mode: fullscreen-ish single image preview inside the popup
swayimg.viewer.set_window_background(0xff1a1a1a)
swayimg.viewer.set_default_scale("optimal")
swayimg.viewer.set_text("bottomleft", {
  "  hl/←→ next/prev   ·   Space/Esc back   ·   Enter apply  "
})

-- ============================================================
-- Gallery key bindings
-- ============================================================
swayimg.gallery.on_key("Return", function()
  local img = swayimg.gallery.get_image()
  local f = io.open("/tmp/hypr-wallpaper-selected", "w")
  if f then f:write(img.path); f:close() end
  swayimg.exit()
end)
swayimg.gallery.on_key("Escape", function() swayimg.exit() end)

-- Enter viewer mode to preview the focused image
swayimg.gallery.on_key("space", function() swayimg.set_mode("viewer") end)

-- Navigation: arrows + vim-style hjkl.
swayimg.gallery.on_key("Left",  function() swayimg.gallery.switch_image("left") end)
swayimg.gallery.on_key("Down",  function() swayimg.gallery.switch_image("down") end)
swayimg.gallery.on_key("Up",    function() swayimg.gallery.switch_image("up") end)
swayimg.gallery.on_key("Right", function() swayimg.gallery.switch_image("right") end)
swayimg.gallery.on_key("h",     function() swayimg.gallery.switch_image("left") end)
swayimg.gallery.on_key("j",     function() swayimg.gallery.switch_image("down") end)
swayimg.gallery.on_key("k",     function() swayimg.gallery.switch_image("up") end)
swayimg.gallery.on_key("l",     function() swayimg.gallery.switch_image("right") end)
swayimg.gallery.on_key("Home",  function() swayimg.gallery.switch_image("first") end)
swayimg.gallery.on_key("End",   function() swayimg.gallery.switch_image("last") end)

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
  swayimg.exit()
end)

-- Navigate next/prev image in viewer mode
swayimg.viewer.on_key("h",     function() swayimg.viewer.switch_image("prev") end)
swayimg.viewer.on_key("l",     function() swayimg.viewer.switch_image("next") end)
swayimg.viewer.on_key("Left",  function() swayimg.viewer.switch_image("prev") end)
swayimg.viewer.on_key("Right", function() swayimg.viewer.switch_image("next") end)
LUA

# Clear stale selection from any previous run.
rm -f "$SELECTED_FILE"

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
    "$HOME/.config/hypr/scripts/WallustSwww.sh" "$sel" 2>/dev/null || true
    "$HOME/.config/hypr/scripts/Refresh.sh" 2>/dev/null || true
  fi
) &
disown

# --config loads our Lua as the swayimg config (replaces init.lua role).
# Note: --execute takes inline Lua code, not a file path — wrong for us.
# --from-file passes every image path explicitly so we don't depend on
# swayimg's directory-loading behavior.
hyprctl dispatch \
  "hl.dsp.exec_cmd(\"swayimg --gallery --class=HyprWallpaperPicker --config=$LUA_SCRIPT --from-file=$LIST_FILE\", { float = true, size = \"$W $H\", move = \"$X $Y\" })" \
  >/dev/null 2>&1
