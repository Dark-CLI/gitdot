#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# For applying Pre-configured Monitor Profiles

# Check if rofi is already running
if pidof rofi > /dev/null; then
  pkill rofi
fi

# Variables
iDIR="$HOME/.config/swaync/images"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
monitor_dir="$HOME/.config/hypr/Monitor_Profiles"
target="$HOME/.config/hypr/monitors.conf"
rofi_theme="$HOME/.config/rofi/config-Monitors.rasi"
msg='❗NOTE:❗ This will overwrite $HOME/.config/hypr/monitors.conf'

# Define the list of files to ignore
ignore_files=(
  "README"
)

# list of Monitor Profiles, sorted alphabetically with numbers first
mon_profiles_list=$(find -L "$monitor_dir" -maxdepth 1 -type f | sed 's/.*\///' | sed 's/\.conf$//' | sort -V)

# Remove ignored files from the list
for ignored_file in "${ignore_files[@]}"; do
    mon_profiles_list=$(echo "$mon_profiles_list" | grep -v -E "^$ignored_file$")
done

# Source rofi menu helper with state management
source "$SCRIPTSDIR/rofi_menu.sh"

# Rofi Menu with state (remembers last selection)
chosen_file=$(rofi_menu_with_state "monitor_profiles" "$mon_profiles_list" "$rofi_theme")

if [[ -n "$chosen_file" ]]; then
    full_path="$monitor_dir/$chosen_file.conf"
    cp "$full_path" "$target"

    notify-send -u low -i "$iDIR/ja.png" "$chosen_file" "Monitor Profile Loaded"

    # Sync tablet transform with monitor rotation (if profile changed)
    ${SCRIPTSDIR}/SyncTabletTransform.sh
fi

sleep 1
${SCRIPTSDIR}/RefreshNoWaybar.sh &