#!/usr/bin/env bash
# Glow-rendered help popup for the SUPER+SHIFT+D launcher.
# Mirrors KeyHints.sh: single-instance, centered, transient .md file.

EXISTING=$(hyprctl clients -j 2>/dev/null | jq -r '.[] | select(.class == "HyprLauncherHelp") | .address' | head -1)
if [ -n "$EXISTING" ]; then
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$EXISTING\" })" >/dev/null 2>&1
  exit 0
fi

TMP_MD="/tmp/hypr-launcher-help.md"

KW=18   # fixed shortcut column width so every section aligns
SEP="$(printf -- '─%.0s' $(seq 1 $((KW + 2))))──────────────────────────────"

row() { printf "  %-${KW}s  %s\n" "$1" "$2"; }

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
# Launcher

A fuzzy launcher in a kitty popup, bound to **`SUPER + SHIFT + D`**.

Type to filter. The first character switches mode:

EOF
emit_section \
  '(no prefix)'   'Installed applications' \
  '/'             'Directories under $HOME — opens kitty+tmux in that path' \
  '>'             'Shell commands — top row runs the literal query, rest is your history' \
  '!'             'Power actions — lock / logout / suspend / reboot / shutdown' \
  '?'             'Cheat sheet (rows inside fzf)' \
  'F1'            'This screen'

cat <<'EOF'

## Keys inside the launcher

EOF
emit_section \
  'Enter'         'Run the highlighted row' \
  'Ctrl-X'        'Run as administrator (polkit dialog)' \
  'Tab'           'Replace the query with the highlighted row' \
  'Esc'           'Close the launcher' \
  'F1'            'Open this help'

cat <<'EOF'

## Examples

- `firefox` — launch Firefox
- `/code` — list dirs under `~` matching “code”, Enter → kitty in that dir with a tmux session
- `> systemctl status sshd` — top row reruns the literal command; you can also pick a past command from history
- `!suspend` — narrow the power menu down to suspend, Enter
- Highlight Thunar, press **Ctrl-X** → polkit asks for your password, Thunar opens as root

## Notes

- App rows ship with a Nerd Font glyph next to the name; the glyph is part of the searchable text, so you can also type the icon.
- Apps with `Terminal=true` in their `.desktop` (htop, vim, ncmpcpp…) open inside a kitty terminal automatically.
- Directories ignored by default: `.git`, `node_modules`, `target`, build/IDE caches. Edit `LauncherBuildCache.sh` to tune.
- Caches live at `~/.cache/hypr-launcher/` (`apps.tsv`, `dirs.tsv`). The dir cache refreshes if older than 1h.

_Press `q` to close this window._
EOF
} > "$TMP_MD"

read -r MON_X MON_Y MON_W MON_H < <(hyprctl monitors -j 2>/dev/null | \
  jq -r '.[] | select(.focused == true) | "\(.x) \(.y) \(.width) \(.height)"')
[ -z "$MON_W" ] && MON_W=2560
[ -z "$MON_H" ] && MON_H=1440
[ -z "$MON_X" ] && MON_X=0
[ -z "$MON_Y" ] && MON_Y=0
W=$((MON_W * 52 / 100))
H=$((MON_H * 60 / 100))
X=$((MON_X + (MON_W - W) / 2))
Y=$((MON_Y + (MON_H - H) / 2))

hyprctl dispatch \
  "hl.dsp.exec_cmd(\"kitty --class HyprLauncherHelp --title 'Launcher Help' -- bash -c 'glow -p $TMP_MD; sleep 0.1'\", { float = true, size = \"$W $H\", move = \"$X $Y\" })" \
  >/dev/null 2>&1
