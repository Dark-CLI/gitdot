#!/usr/bin/env bash
# Pick a waybar style (.css) and symlink it to style.css, then refresh.
# Runs inside the HyprWaybarStyles kitty popup (see WaybarStylesLaunch.sh).

set -u

waybar_styles="$HOME/.config/waybar/style"
waybar_style="$HOME/.config/waybar/style.css"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
MARKER='👉'
msg='NOTE: Some waybar STYLES are NOT fully compatible with some LAYOUTS'

# Current style (basename of the symlink target, minus .css).
current_name=$(basename "$(readlink -f "$waybar_style")" .css)

# fzf list: current style first (so it's the default highlight and gets
# the 👉 marker), everything else after in sort order. Marker is stripped
# before symlinking.
{
  if [[ -n "$current_name" ]]; then
    printf '%s %s\n' "$MARKER" "$current_name"
  fi
  find -L "$waybar_styles" -maxdepth 1 -type f -name '*.css' \
    -exec basename {} .css \; |
    sort |
    grep -Fxv -- "$current_name"
} > /tmp/hypr-waybar-styles.list

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
    < /tmp/hypr-waybar-styles.list
)
rm -f /tmp/hypr-waybar-styles.list

[[ -z "$choice" ]] && exit 0

choice=${choice#"$MARKER "}
ln -sf "$waybar_styles/$choice.css" "$waybar_style"
"$SCRIPTSDIR/Refresh.sh" &
