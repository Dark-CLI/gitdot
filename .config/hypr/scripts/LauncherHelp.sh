#!/usr/bin/env bash
# Glow-rendered help for the SUPER+D launcher. Spawns a separate kitty
# popup (class HyprLauncherHelp) via Hyprland — that way glow runs in
# its own fresh terminal with no escape-leak issues, and the window
# rule pins it above the launcher.

EXISTING=$(hyprctl clients -j 2>/dev/null | jq -r '.[] | select(.class == "HyprLauncherHelp") | .address' | head -1)
if [ -n "$EXISTING" ]; then
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$EXISTING\" })" >/dev/null 2>&1
  exit 0
fi

TMP_MD="/tmp/hypr-launcher-help.md"

# Emit a real markdown table — glow auto-sizes columns and word-wraps
# descriptions cleanly, unlike the fixed-width code block we used to
# build by hand.
emit_section() {
  echo
  echo '| Shortcut | What it does |'
  echo '|----------|--------------|'
  while [ $# -gt 0 ]; do
    printf '| %s | %s |\n' "$1" "$2"
    shift 2
  done
  echo
}

{
cat <<'EOF'
# Launcher

A fuzzy launcher in a kitty popup, bound to **`SUPER + D`**.

Type to filter. The first character switches mode:

EOF
emit_section \
  '(no prefix)'   'Installed applications' \
  '/'             'Directories under $HOME — opens kitty+tmux in that path' \
  '>'             'Shell commands — top row runs the literal query, rest is your history' \
  '!'             'Power actions — lock / blank screen / logout / suspend / reboot / shutdown' \
  'F1'            'This screen'

cat <<'EOF'

## Keys inside the launcher

EOF
emit_section \
  'Enter'         'Run the highlighted row' \
  'Ctrl-X'        'Run as administrator (polkit dialog)' \
  'Ctrl-E'        'Open the row'\''s .desktop in nvim (apps only)' \
  'Tab'           'Replace the query with the highlighted row' \
  'Esc'           'Close the launcher' \
  'F1'            'Open this help' \
  'F5'            'Force-rebuild the apps + dirs cache'

cat <<'EOF'

## Examples

- `firefox` — launch Firefox
- `/code` — list dirs under `~` matching “code”, Enter → kitty in that dir with a tmux session
- `> systemctl status sshd` — top row reruns the literal command; you can also pick a past command from history
- `!suspend` — narrow the power menu down to suspend, Enter
- Highlight Thunar, press **Ctrl-X** → polkit asks for your password, Thunar opens as root
- Highlight an app, press **Ctrl-E** → its `.desktop` opens in nvim inside the launcher; close nvim to return

## Notes

- Apps with `Terminal=true` in their `.desktop` (htop, vim, ncmpcpp…) open inside a kitty terminal automatically.
- Directories ignored by default: `.git`, `node_modules`, `target`, build/IDE caches. Edit `LauncherBuildCache.sh` to tune.
- Caches live at `~/.cache/hypr-launcher/` (`apps.tsv`, `dirs.tsv`). The dir cache refreshes if older than 1h.

_Press `q` to close this window._
EOF
} > "$TMP_MD"

read -r MON_X MON_Y MON_W MON_H < <(hyprctl monitors -j 2>/dev/null |
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
