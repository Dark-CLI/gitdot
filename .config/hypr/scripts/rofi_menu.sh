#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Rofi Menu Helper with State Management
# Remembers last selected item and restores it on next menu open
# Usage: choice=$(rofi_menu_with_state "menu_name" "menu_options" [rofi_theme])

rofi_menu_with_state() {
  local menu_name=$1           # Identifier for this menu (e.g., "wallpaper", "theme")
  local menu_options=$2        # The menu items (newline separated)
  local rofi_theme=${3:-""}    # Optional rofi theme config path

  # Validate inputs
  if [ -z "$menu_name" ] || [ -z "$menu_options" ]; then
    echo "Error: rofi_menu_with_state requires menu_name and menu_options" >&2
    return 1
  fi

  # Create cache directory if it doesn't exist
  local cache_dir="$HOME/.cache/hypr"
  mkdir -p "$cache_dir" 2>/dev/null

  # State file for this menu
  local state_file="$cache_dir/rofi_${menu_name}_last"

  # Load last selected item (if exists)
  local last_selected=""
  if [ -f "$state_file" ]; then
    last_selected=$(cat "$state_file" 2>/dev/null)
  fi

  # Build rofi command
  local rofi_cmd="rofi -i -dmenu"

  # Add theme if provided
  if [ -n "$rofi_theme" ]; then
    rofi_cmd="$rofi_cmd -config $rofi_theme"
  fi

  # Add filter for last selected item (if it exists)
  if [ -n "$last_selected" ]; then
    rofi_cmd="$rofi_cmd -filter \"$last_selected\""
  fi

  # Show menu and get selection
  local choice=$(echo "$menu_options" | eval "$rofi_cmd")

  # If user made a selection, save it
  if [ -n "$choice" ]; then
    echo "$choice" > "$state_file"
  fi

  # Return the choice (empty if cancelled)
  echo "$choice"
}

# Export function for use in sourced scripts
export -f rofi_menu_with_state
