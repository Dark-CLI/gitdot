#!/usr/bin/env bash
# Modified version of Refresh.sh that doesn't restart waybar.
# Used by automatic wallpaper change to refresh Wallust + SwayNC only.

SCRIPTSDIR=$HOME/.config/hypr/scripts
UserScripts=$HOME/.config/hypr/UserScripts

# Define file_exists function
file_exists() {
    if [ -e "$1" ]; then
        return 0  # File exists
    else
        return 1  # File does not exist
    fi
}

# quit ags & relaunch ags
#ags -q && ags &

# quit quickshell & relaunch quickshell
#pkill qs && qs &

# Wallust refresh (synchronous to ensure colors are ready)
${SCRIPTSDIR}/WallustSwww.sh
sleep 0.2

# reload waybar styles (SIGUSR2 reloads CSS without full restart)
pkill -SIGUSR2 waybar

# reload swaync
swaync-client --reload-config

# Relaunching rainbow borders if the script exists
sleep 1
if file_exists "${UserScripts}/RainbowBorders.sh"; then
    ${UserScripts}/RainbowBorders.sh &
fi


exit 0