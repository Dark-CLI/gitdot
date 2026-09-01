#!/usr/bin/env bash
# Hyprland get-started intro
# Brief tutorial for new tiling-WM users, rendered with `glow` in a kitty popup.

# If a cheat sheet popup is already open, just focus it instead of spawning
# a second one. F1 then behaves like a toggle-or-raise.
EXISTING=$(hyprctl clients -j 2>/dev/null | jq -r '.[] | select(.class == "HyprCheatSheet") | .address' | head -1)
if [ -n "$EXISTING" ]; then
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$EXISTING\" })" >/dev/null 2>&1
  exit 0
fi

# Use a stable path (not mktemp) and no EXIT trap — the trap would delete the
# file before the async kitty/glow had a chance to read it.
TMP_MD="/tmp/hypr-cheatsheet.md"

# Fixed column widths. Using preformatted blocks (not markdown tables) so
# every section has the EXACT same shortcut column width — glow sizes each
# markdown table independently which is why tables drifted apart.
KW=26   # shortcut column width
SEP="$(printf -- '─%.0s' $(seq 1 $((KW + 2))))──────────────────────────────"

row() {
  printf "  %-${KW}s  %s\n" "$1" "$2"
}

emit_section() {
  echo '```'
  printf "  %-${KW}s  %s\n" "Shortcut" "What it does"
  echo "  $SEP"
  while [ $# -gt 0 ]; do
    row "$1" "$2"
    shift 2
  done
  echo '```'
}

{
cat <<'EOF'
# Welcome to Hyprland

Hyprland is a **tiling Wayland compositor**: it manages your windows in a
grid that fills the screen automatically. No overlapping, no minimizing,
no clicking around. Almost everything you do is from the keyboard.

The **SUPER** key (Windows / Cmd) is the modifier — almost every shortcut
starts with it.

---

## The 60-second basics

EOF
emit_section \
  'SUPER + Return'           'Open a terminal' \
  'SUPER + D'                'App launcher (start typing)' \
  'SUPER + Q'                'Close the focused window' \
  'SUPER + F2'               'Search every shortcut (cheat sheet)' \
  'SUPER + F1'               'This screen'

cat <<'EOF'

### Moving around windows (vim-style)

EOF
emit_section \
  'SUPER + h / j / k / l'    'Focus left / down / up / right' \
  'SUPER + SHIFT + h/j/k/l'  'Move window (edge-snap by default; toggle modes)' \
  'SUPER + CTRL + h/j/k/l'   'Resize window (hold to repeat)'

cat <<'EOF'

### Workspaces (virtual desktops)

EOF
emit_section \
  'SUPER + 1..9, 0'          'Jump to workspace 1-10' \
  'SUPER + SHIFT + 1..0'     'Move focused window to that workspace' \
  'SUPER + scroll'           'Scroll through workspaces'

cat <<'EOF'

### Window state

EOF
emit_section \
  'SUPER + SHIFT + F'        'Fullscreen' \
  'SUPER + Space'            'Toggle floating (escape tiling)' \
  'SUPER + SHIFT + Space'    'Center floating window on screen' \
  'SUPER + SHIFT + BackSpace' 'Toggle float move mode (snap / step)' \
  'SUPER + SHIFT + Return'   'Dropdown terminal (toggle)'

cat <<'EOF'

---

## Built-in extras on this rig

- **Dropdown terminal** — `SUPER + SHIFT + Return` slides a kitty
  terminal in/out; keeps the same tmux session across toggles.
- **Gap control** — `SUPER + =` / `SUPER + -` resize the gaps between
  windows live (hold to repeat); `SUPER + Backspace` resets.
- **Floating-window movement** — `SUPER + SHIFT + h/j/k/l` moves a
  floating window. Default **snap** mode slams the edge to the
  matching side of the usable area (above the bar, inside the gaps).
  `SUPER + SHIFT + Backspace` toggles **step** mode (80px nudges, hold
  to repeat). `SUPER + SHIFT + Space` re-centers it.
- **Wallpaper picker** — `SUPER + W` opens a thumbnail gallery
  (swayimg). Navigate with `hjkl`/arrows, `/` to fuzzy-search by name,
  `Space` to preview with blurred fill, `Enter` to apply, `Esc` cancels.
  Colors auto-regenerate via wallust. `SUPER + SHIFT + W` applies
  effects; `CTRL + ALT + W` sets a random wallpaper.
- **Screenshots** — `SUPER + Print` (full), `SUPER + SHIFT + Print`
  (select area), `SUPER + SHIFT + S` (with editor).
- **Clipboard history** — `SUPER + V` fuzzy-picks a past clipboard
  entry (Enter applies, `Ctrl-E` edits in nvim, `Ctrl-X` deletes,
  `Ctrl-D` wipes).
- **File browser** — `SUPER + E` opens **yazi** in a floating kitty
  popup. `hjkl` to navigate, `Enter` to open, `q` to quit.
- **Apps submap** — `SUPER + S` enters a bucket, then one letter
  launches: `w` winbox · `d` discord · `t` telegram · `s` steam ·
  `b` btop (in a floating popup). `Escape` exits without launching.
- **Power & lock** — `CTRL + ALT + L` lock, `CTRL + ALT + P` power menu,
  `CTRL + ALT + Home` blank the screens (wakes on mouse/key),
  `CTRL + ALT + End` suspend. Media keys, volume, mute, blank and
  suspend all keep working while hyprlock is up.
- **Workspace toggle** — `SUPER + N` on the current workspace jumps
  back to the previous one (back-and-forth).
- **Quick edit config** — `SUPER + SHIFT + E` opens a menu to edit any
  config file (uses **nvim**).

---

## Quick tips

- New windows take whatever empty space exists. To make more room, close
  something or move a window to another workspace.
- If a window opens floating in the center, **`SUPER + Space`** toggles
  it back into the tile grid.
- Stuck? **`SUPER + F2`** searches every binding by description.

_Press `q` to close this window._
EOF
} > "$TMP_MD"

# Get focused monitor size to compute 54% x 67% window size.
read -r MON_W MON_H < <(hyprctl monitors -j 2>/dev/null | \
  jq -r '.[] | select(.focused == true) | "\(.width) \(.height)"')
[ -z "$MON_W" ] && MON_W=2560
[ -z "$MON_H" ] && MON_H=1440
W=$((MON_W * 54 / 100))
H=$((MON_H * 67 / 100))

# Spawn floating window at computed size, then center it using Hyprland's built-in function.
hyprctl dispatch \
  "hl.dsp.exec_cmd(\"kitty --class HyprCheatSheet --title 'Welcome to Hyprland' -- bash -c 'glow -p $TMP_MD; sleep 0.1'\", { float = true, size = \"$W $H\" })" \
  >/dev/null 2>&1

# Wait for window to spawn and ensure it's focused, then center it
sleep 0.1
hyprctl dispatch "hl.dsp.focus({ class = \"HyprCheatSheet\" })" >/dev/null 2>&1
hyprctl dispatch "hl.dsp.window.center({ respect_reserved = true })" >/dev/null 2>&1
