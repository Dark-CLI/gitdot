#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Power menu using systemctl (simplified, more reliable than wlogout)
# Replaces wlogout to avoid logout crashes and unresponsive state

# Use rofi for a simple power menu instead of wlogout
# This avoids the complex wlogout configuration issues

rofi_theme="$HOME/.config/rofi/config-powermenu.rasi"

# Power menu options
menu_options="Logout\nLock\nSuspend\nReboot\nShutdown"

# Show rofi menu
chosen=$(echo -e "$menu_options" | rofi -i -dmenu -theme-str 'element-text { font: "Fira Sans 14"; }' -p "Power Menu" 2>/dev/null)

# Execute chosen action
case "$chosen" in
    "Logout")
        loginctl terminate-session "$XDG_SESSION_ID"
        ;;
    "Lock")
        "$HOME/.config/hypr/scripts/LockScreen.sh"
        ;;
    "Suspend")
        systemctl suspend
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Shutdown")
        systemctl poweroff
        ;;
    *)
        echo "Power menu cancelled"
        exit 0
        ;;
esac
