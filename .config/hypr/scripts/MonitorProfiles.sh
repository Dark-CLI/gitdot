#!/usr/bin/env bash
# Pick a monitor profile and copy it over monitors.conf and monitors.lua.
# Invoked from Kool_Quick_Settings.sh (inside a kitty popup) — no
# separate launcher script needed.

set -u

iDIR="$HOME/.config/swaync/images"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
monitor_dir="$HOME/.config/hypr/Monitor_Profiles"
target_conf="$HOME/.config/hypr/monitors.conf"
target_lua="$HOME/.config/hypr/monitors.lua"
STATE="$HOME/.cache/hypr/monitor_profiles_last"
mkdir -p "$(dirname "$STATE")"

# Files ignored in the profile list.
ignore_files=(README)

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
      --bind 'esc:abort' \
      --header='Pick a monitor profile'
)

[[ -z "$chosen" ]] && exit 0

# Only use .lua file (monitors.conf causes issues with Lua parser)
lua_profile="$monitor_dir/$chosen.lua"
if [[ -f "$lua_profile" ]]; then
  cp "$lua_profile" "$target_lua"
else
  echo "Error: $lua_profile not found" >&2
  exit 1
fi

printf '%s' "$chosen" >"$STATE"

notify-send -u low -i "$iDIR/ja.png" "$chosen" "Monitor Profile Loaded"

# Reload Hyprland to apply the new monitor configuration
sleep 0.5
hyprctl reload
