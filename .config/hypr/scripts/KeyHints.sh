#!/usr/bin/env bash
# Hyprland get-started intro
# Brief tutorial for new tiling-WM users, rendered with `glow` in a kitty popup.

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
  'SUPER + SHIFT + h/j/k/l'  'Move the focused window' \
  'SUPER + CTRL + h/j/k/l'   'Resize the focused window'

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
  'SUPER + SHIFT + Return'   'Dropdown terminal (toggle)'

cat <<'EOF'

---

## Built-in extras on this rig

- **Dropdown terminal** — `SUPER + SHIFT + Return` slides a kitty
  terminal in/out; keeps the same tmux session across toggles.
- **Gap control** — `SUPER + =` / `SUPER + -` resize the gaps between
  windows live; `SUPER + Backspace` resets.
- **Wallpaper** — `SUPER + W` picks a wallpaper; `SUPER + SHIFT + W`
  applies effects; `CTRL + ALT + W` random.
- **Screenshots** — `SUPER + Print` (full), `SUPER + SHIFT + Print`
  (select area), `SUPER + SHIFT + S` (with editor).
- **Clipboard history** — `SUPER + ALT + V` searches clipboard.
- **Power & lock** — `CTRL + ALT + L` lock, `CTRL + ALT + P` power menu.
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

# Compute current gaps so the popup respects whatever gaps_out is set to right
# now (rather than a hardcoded 30 30). The hyprctl output looks like
# "css gap data: 30 30 30 30" — grab the first number.
GAPS=$(hyprctl getoption general:gaps_out 2>/dev/null | grep -oE '[0-9]+' | head -1)
[ -z "$GAPS" ] && GAPS=30

# Get focused monitor logical size to compute 54% x 67% size
read -r MON_W MON_H < <(hyprctl monitors -j 2>/dev/null | \
  jq -r '.[] | select(.focused == true) | "\(.width) \(.height)"')
[ -z "$MON_W" ] && MON_W=2560
[ -z "$MON_H" ] && MON_H=1440
W=$((MON_W * 54 / 100))
H=$((MON_H * 67 / 100))

# Spawn floating at current-gaps position with the computed size. Using
# exec_cmd rules ensures the window appears at the right spot immediately
# (no flicker from a default position).
hyprctl dispatch \
  "hl.dsp.exec_cmd(\"kitty --class HyprCheatSheet --title 'Welcome to Hyprland' -- bash -c 'glow -p $TMP_MD; sleep 0.1'\", { float = true, size = \"$W $H\", move = \"$GAPS $GAPS\" })" \
  >/dev/null 2>&1
