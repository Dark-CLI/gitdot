#!/usr/bin/env bash
# Pick a waybar layout (config file) and symlink it to `config`, then
# refresh. "no panel" kills waybar entirely.
# Runs inside the HyprWaybarLayout kitty popup (see WaybarLayoutLaunch.sh).

set -u

waybar_layouts="$HOME/.config/waybar/configs"
waybar_config="$HOME/.config/waybar/config"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
MARKER='👉'
msg='NOTE: Some waybar LAYOUTS are NOT fully compatible with some STYLES'

# Current layout (basename of the symlink target).
current_name=$(basename "$(readlink -f "$waybar_config")")

# fzf list: current layout first (default highlight, with 👉), rest
# sorted after. Marker is stripped before symlinking.
{
  if [[ -n "$current_name" ]]; then
    printf '%s %s\n' "$MARKER" "$current_name"
  fi
  find -L "$waybar_layouts" -maxdepth 1 -type f -printf '%f\n' |
    sort |
    grep -Fxv -- "$current_name"
} > /tmp/hypr-waybar-layouts.list

choice=$(
  fzf \
    --prompt='> ' \
    --pointer='▶' \
    --marker='*' \
    --info=inline \
    --no-mouse \
    --reverse \
    --tiebreak=index \
    --bind 'esc:abort' \
    --header="$msg" \
    < /tmp/hypr-waybar-layouts.list
)
rm -f /tmp/hypr-waybar-layouts.list

[[ -z "$choice" ]] && exit 0

choice=${choice#"$MARKER "}

case "$choice" in
  "no panel")
    pgrep -x waybar && pkill waybar || true
    ;;
  *)
    ln -sf "$waybar_layouts/$choice" "$waybar_config"
    "$SCRIPTSDIR/Refresh.sh" &
    ;;
esac
