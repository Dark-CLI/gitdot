#!/usr/bin/env bash
# Pick a monitor profile and copy it over monitors.conf.
# Invoked from Kool_Quick_Settings.sh (inside a kitty popup) — no
# separate launcher script needed.

set -u

iDIR="$HOME/.config/swaync/images"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
monitor_dir="$HOME/.config/hypr/Monitor_Profiles"
target="$HOME/.config/hypr/monitors.conf"
STATE="$HOME/.cache/hypr/monitor_profiles_last"
mkdir -p "$(dirname "$STATE")"

# Files ignored in the profile list.
ignore_files=(README)

# Restore last selection as the initial fzf query.
last=""
[[ -f "$STATE" ]] && last=$(<"$STATE")

# Build the profile list (basename minus .conf), sorted, minus ignores.
build_list() {
  find -L "$monitor_dir" -maxdepth 1 -type f -name '*.conf' |
    sed 's/.*\///; s/\.conf$//' |
    sort -V |
    grep -Ev "^($(IFS='|'; echo "${ignore_files[*]}"))$"
}

chosen=$(
  build_list |
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
      --header='Pick a monitor profile — overwrites monitors.conf'
)

[[ -z "$chosen" ]] && exit 0

cp "$monitor_dir/$chosen.conf" "$target"
printf '%s' "$chosen" >"$STATE"

notify-send -u low -i "$iDIR/ja.png" "$chosen" "Monitor Profile Loaded"

# Sync tablet transform with monitor rotation (if profile changed).
"$SCRIPTSDIR/SyncTabletTransform.sh"

sleep 1
"$SCRIPTSDIR/RefreshNoWaybar.sh" &
