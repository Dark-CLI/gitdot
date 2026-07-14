#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Rofi menu for KooL Hyprland Quick Settings (SUPER SHIFT E)
# Updated for UserConfigs/configs separation

# Modify this config file for default terminal and EDITOR
config_file="$HOME/.config/hypr/UserConfigs/01-UserDefaults.conf"

tmp_config_file=$(mktemp)
sed 's/^\$//g; s/ = /=/g' "$config_file" > "$tmp_config_file"
source "$tmp_config_file"
# ##################################### #

# variables
configs="$HOME/.config/hypr/configs"
UserConfigs="$HOME/.config/hypr/UserConfigs"
msg='Choose what to do'
iDIR="$HOME/.config/swaync/images"
scriptsDir="$HOME/.config/hypr/scripts"
UserScripts="$HOME/.config/hypr/UserScripts"

# Function to show info notification
show_info() {
    notify-send -i "$iDIR/info.png" "Info" "$1"
}

# Launch a GUI app OUTSIDE this kitty popup so the popup closes as soon
# as the choice is made. hyprctl exec_cmd parents the process to
# Hyprland, so it outlives us. Error notification if the binary is
# missing (rather than a silent shell exit).
spawn_gui() {
    local bin="$1"
    if ! command -v "$bin" >/dev/null 2>&1; then
        notify-send -i "$iDIR/error.png" "E-R-R-O-R" "Install $bin first"
        return 1
    fi
    hyprctl dispatch "hl.dsp.exec_cmd([[$bin]])" >/dev/null 2>&1
}

# Function to display the menu options without numbers
menu() {
    cat <<EOF
--- HYPRLAND LUA CONFIGURATION ---
Edit Main Config (hyprland.lua)
Edit Core Settings (config.lua)
Edit Environment (env.lua)
Edit System Keybinds (system.lua)
Edit Custom Keybinds (custom.lua)
Edit Window Rules (windows.lua)
Edit Animations (animations.lua)
Edit Startup Services (boot.lua)
--- UTILITIES ---
Choose Kitty Terminal Theme
Configure Monitors (nwg-displays)
Configure Workspace Rules (nwg-displays)
GTK Settings (nwg-look)
QT Apps Settings (qt6ct)
QT Apps Settings (qt5ct)
Choose Hyprland Animations
Choose Monitor Profiles
Choose Rofi Themes
Search for Keybinds
Toggle Game Mode
Switch Dark-Light Theme
EOF
}

# Main function to handle menu selection
main() {
    choice=$(menu | fzf \
        --prompt='> ' --pointer='▶' --marker='*' \
        --info=inline --no-mouse --reverse --tiebreak=index \
        --bind 'esc:abort' --header="$msg")
    
    # Map choices to corresponding files
    case "$choice" in
    	"Edit Main Config (hyprland.lua)") file="$HOME/.config/hypr/hyprland.lua" ;;
        "Edit Core Settings (config.lua)") file="$HOME/.config/hypr/lua/core/config.lua" ;;
        "Edit Environment (env.lua)") file="$HOME/.config/hypr/lua/core/env.lua" ;;
        "Edit System Keybinds (system.lua)") file="$HOME/.config/hypr/lua/binds/system.lua" ;;
        "Edit Custom Keybinds (custom.lua)") file="$HOME/.config/hypr/lua/binds/custom.lua" ;;
        "Edit Window Rules (windows.lua)") file="$HOME/.config/hypr/lua/rules/windows.lua" ;;
        "Edit Animations (animations.lua)") file="$HOME/.config/hypr/lua/rules/animations.lua" ;;
        "Edit Startup Services (boot.lua)") file="$HOME/.config/hypr/lua/startup/boot.lua" ;;
        "Choose Kitty Terminal Theme") $scriptsDir/Kitty_themes.sh ;;
        "Configure Monitors (nwg-displays)")           spawn_gui nwg-displays ;;
        "Configure Workspace Rules (nwg-displays)")    spawn_gui nwg-displays ;;
        "GTK Settings (nwg-look)")                     spawn_gui nwg-look ;;
        "QT Apps Settings (qt6ct)")                    spawn_gui qt6ct ;;
        "QT Apps Settings (qt5ct)")                    spawn_gui qt5ct ;;
        "Choose Hyprland Animations") $scriptsDir/Animations.sh ;;
        "Choose Monitor Profiles") $scriptsDir/MonitorProfiles.sh ;;
        "Choose Rofi Themes") $scriptsDir/RofiThemeSelector.sh ;;
        "Search for Keybinds") $scriptsDir/KeyBinds.sh ;;
        "Toggle Game Mode") $scriptsDir/GameMode.sh ;;
        "Switch Dark-Light Theme") $scriptsDir/DarkLight.sh ;;
        *) return ;;  # Do nothing for invalid choices
    esac

    # Open the selected file with the editor INSIDE this kitty popup
    # (the whole hub is already running in a floating kitty). Falls back
    # to nvim if $edit isn't set by 01-UserDefaults.conf. Popup closes
    # automatically when the editor exits.
    if [ -n "${file:-}" ]; then
        ${edit:-nvim} "$file"
    fi
}

main
