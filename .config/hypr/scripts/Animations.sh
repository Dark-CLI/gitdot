#!/usr/bin/env bash
# Pick a Hyprland animation preset and copy it to UserAnimations.conf.
# Runs inside a HyprAnimations kitty popup (see AnimationsLaunch.sh).

set -u

iDIR="$HOME/.config/swaync/images"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
animations_dir="$HOME/.config/hypr/animations"
UserConfigs="$HOME/.config/hypr/UserConfigs"
STATE="$HOME/.cache/hypr/animations_last"
mkdir -p "$(dirname "$STATE")"

# Restore last selection as the initial query so re-opening lands on it.
last=""
[[ -f "$STATE" ]] && last=$(<"$STATE")

chosen=$(
  find -L "$animations_dir" -maxdepth 1 -type f -name '*.conf' |
    sed 's/.*\///; s/\.conf$//' |
    sort -V |
    fzf \
      --prompt='> ' \
      --pointer='▶' \
      --marker='*' \
      --info=inline \
      --no-mouse \
      --reverse \
      --tiebreak=index \
      --query="$last" \
      --bind 'esc:abort' \
      --header='Pick an animation preset — copies to UserAnimations.conf'
)

[[ -z "$chosen" ]] && exit 0

cp "$animations_dir/$chosen.conf" "$UserConfigs/UserAnimations.conf"
printf '%s' "$chosen" >"$STATE"

notify-send -u low -i "$iDIR/ja.png" "$chosen" "Hyprland Animation Loaded"

sleep 1
"$SCRIPTSDIR/RefreshNoWaybar.sh"
