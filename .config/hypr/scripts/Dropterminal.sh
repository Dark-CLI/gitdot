#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
#
# Made and brought to by Kiran George
# /* -- ✨ https://github.com/SherLock707 ✨ -- */  ##
# Dropdown Terminal
# Usage: ./Dropdown.sh [-d] <terminal_command>
# Example: ./Dropdown.sh foot
#          ./Dropdown.sh -d foot (with debug output)
#          ./Dropdown.sh "kitty -e zsh"
#          ./Dropdown.sh "alacritty --working-directory /home/user"

DEBUG=false
SPECIAL_WS="special:scratchpad"
ADDR_FILE="/tmp/dropdown_terminal_addr"

# Dropdown size and position configuration (percentages)
WIDTH_PERCENT=54  # Width as percentage of screen width
HEIGHT_PERCENT=67 # Height as percentage of screen height
X_PERCENT=1       # X position as percentage from left (gap-aware)
Y_PERCENT=2       # Y position as percentage from top (gap-aware)

# Animation settings
ANIMATION_DURATION=100 # milliseconds
SLIDE_STEPS=5
SLIDE_DELAY=5 # milliseconds between steps

# Parse arguments
if [ "$1" = "-d" ]; then
  DEBUG=true
  shift
fi

# Check for special actions
if [ "$1" = "reposition" ]; then
  REPOSITION_ONLY=true
  shift
else
  REPOSITION_ONLY=false
fi

TERMINAL_CMD="$1"

# Debug echo function
debug_echo() {
  if [ "$DEBUG" = true ]; then
    echo "$@"
  fi
}

# Validate input
if [ -z "$TERMINAL_CMD" ]; then
  echo "Missing terminal command. Usage: $0 [-d] <terminal_command>"
  echo "Examples:"
  echo "  $0 foot"
  echo "  $0 -d foot (with debug output)"
  echo "  $0 'kitty -e zsh'"
  echo "  $0 'alacritty --working-directory /home/user'"
  echo ""
  echo "Edit the script to modify size and position:"
  echo "  WIDTH_PERCENT  - Width as percentage of screen (default: 50)"
  echo "  HEIGHT_PERCENT - Height as percentage of screen (default: 50)"
  echo "  Y_PERCENT      - Y position from top as percentage (default: 5)"
  echo "  Note: X position is automatically centered"
  exit 1
fi

# Function to get window geometry
get_window_geometry() {
  local addr="$1"
  hyprctl clients -j | jq -r --arg ADDR "$addr" '.[] | select(.address == $ADDR) | "\(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])"'
}

# Function to show window (positioning - Hyprland handles fade animation)
animate_fade_in() {
  local addr="$1"
  local target_x="$2"
  local target_y="$3"
  local width="$4"
  local height="$5"

  debug_echo "Showing window $addr at position $target_x,$target_y"
  hyprctl dispatch movewindowpixel "exact $target_x $target_y,address:$addr" >/dev/null 2>&1
}

# Function to hide window (Hyprland handles fade animation)
animate_fade_out() {
  local addr="$1"

  debug_echo "Hiding window $addr to scratchpad"
}

# Function to get monitor info including scale and name of focused monitor
get_monitor_info() {
  local monitor_data=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.x) \(.y) \(.width) \(.height) \(.scale) \(.name)"')
  if [ -z "$monitor_data" ] || [[ "$monitor_data" =~ ^null ]]; then
    debug_echo "Error: Could not get focused monitor information"
    return 1
  fi
  echo "$monitor_data"
}

# Function to calculate dropdown position with proper scaling and centering
calculate_dropdown_position() {
  local monitor_info=$(get_monitor_info)

  if [ $? -ne 0 ] || [ -z "$monitor_info" ]; then
    debug_echo "Error: Failed to get monitor info, using fallback values"
    echo "100 100 800 600 fallback-monitor"
    return 1
  fi

  local mon_x=$(echo $monitor_info | cut -d' ' -f1)
  local mon_y=$(echo $monitor_info | cut -d' ' -f2)
  local mon_width=$(echo $monitor_info | cut -d' ' -f3)
  local mon_height=$(echo $monitor_info | cut -d' ' -f4)
  local mon_scale=$(echo $monitor_info | cut -d' ' -f5)
  local mon_name=$(echo $monitor_info | cut -d' ' -f6)

  debug_echo "Monitor info: x=$mon_x, y=$mon_y, width=$mon_width, height=$mon_height, scale=$mon_scale"

  # Validate scale value and provide fallback
  if [ -z "$mon_scale" ] || [ "$mon_scale" = "null" ] || [ "$mon_scale" = "0" ]; then
    debug_echo "Invalid scale value, using 1.0 as fallback"
    mon_scale="1.0"
  fi

  # Calculate logical dimensions by dividing physical dimensions by scale
  local logical_width logical_height
  if command -v bc >/dev/null 2>&1; then
    # Use bc for precise floating point calculation
    logical_width=$(echo "scale=0; $mon_width / $mon_scale" | bc | cut -d'.' -f1)
    logical_height=$(echo "scale=0; $mon_height / $mon_scale" | bc | cut -d'.' -f1)
  else
    # Fallback to integer math (multiply by 100 for precision, then divide)
    local scale_int=$(echo "$mon_scale" | sed 's/\.//' | sed 's/^0*//')
    if [ -z "$scale_int" ]; then scale_int=100; fi

    logical_width=$(((mon_width * 100) / scale_int))
    logical_height=$(((mon_height * 100) / scale_int))
  fi

  # Ensure we have valid integer values
  if ! [[ "$logical_width" =~ ^-?[0-9]+$ ]]; then logical_width=$mon_width; fi
  if ! [[ "$logical_height" =~ ^-?[0-9]+$ ]]; then logical_height=$mon_height; fi

  debug_echo "Physical resolution: ${mon_width}x${mon_height}"
  debug_echo "Logical resolution: ${logical_width}x${logical_height} (physical ÷ scale)"

  # Calculate window dimensions based on LOGICAL space percentages
  local width=$((logical_width * WIDTH_PERCENT / 100))
  local height=$((logical_height * HEIGHT_PERCENT / 100))

  # Get current gaps from Hyprland config
  local gaps_in=$(hyprctl getoption general:gaps_in -j | jq -r '.int' 2>/dev/null || echo 30)
  local gaps_out=$(hyprctl getoption general:gaps_out -j | jq -r '.int' 2>/dev/null || echo 30)

  # Calculate X and Y positions with gap-following (top-left positioning)
  local x_offset=$((logical_width * X_PERCENT / 100 + gaps_out))
  local y_offset=$((logical_height * Y_PERCENT / 100 + gaps_out))

  # Apply monitor offset to get final positions in logical coordinates
  local final_x=$((mon_x + x_offset))
  local final_y=$((mon_y + y_offset))

  debug_echo "Window size: ${width}x${height} (logical pixels)"
  debug_echo "Final position: x=$final_x, y=$final_y (logical coordinates)"
  debug_echo "Hyprland will scale these to physical coordinates automatically"

  echo "$final_x $final_y $width $height $mon_name"
}

# Get the current workspace
CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')

# Function to get stored terminal address
get_terminal_address() {
  if [ -f "$ADDR_FILE" ] && [ -s "$ADDR_FILE" ]; then
    cut -d' ' -f1 "$ADDR_FILE"
  fi
}

# Function to get stored monitor name
get_terminal_monitor() {
  if [ -f "$ADDR_FILE" ] && [ -s "$ADDR_FILE" ]; then
    cut -d' ' -f2- "$ADDR_FILE"
  fi
}

# Function to check if terminal exists
terminal_exists() {
  local addr=$(get_terminal_address)
  if [ -n "$addr" ]; then
    hyprctl clients -j | jq -e --arg ADDR "$addr" 'any(.[]; .address == $ADDR)' >/dev/null 2>&1
  else
    return 1
  fi
}

# Function to check if terminal is in special workspace
terminal_in_special() {
  local addr=$(get_terminal_address)
  if [ -n "$addr" ]; then
    hyprctl clients -j | jq -e --arg ADDR "$addr" 'any(.[]; .address == $ADDR and .workspace.name == "special:scratchpad")' >/dev/null 2>&1
  else
    return 1
  fi
}

# Function to spawn terminal and capture its address
spawn_terminal() {
  debug_echo "Creating new dropdown terminal with command: $TERMINAL_CMD"

  # Calculate dropdown position for later use
  local pos_info=$(calculate_dropdown_position)
  if [ $? -ne 0 ]; then
    debug_echo "Warning: Using fallback positioning"
  fi

  local target_x=$(echo $pos_info | cut -d' ' -f1)
  local target_y=$(echo $pos_info | cut -d' ' -f2)
  local width=$(echo $pos_info | cut -d' ' -f3)
  local height=$(echo $pos_info | cut -d' ' -f4)
  local monitor_name=$(echo $pos_info | cut -d' ' -f5)

  debug_echo "Target position: ${target_x},${target_y}, size: ${width}x${height}"

  # Get window count before spawning
  local windows_before=$(hyprctl clients -j)
  local count_before=$(echo "$windows_before" | jq 'length')

  # Launch terminal directly in special workspace to avoid visible spawn
  hyprctl dispatch exec "[float; size $width $height; workspace special:scratchpad silent] $TERMINAL_CMD --class AlacrittyDropdown"

  # Wait for window to appear
  sleep 0.1

  # Get windows after spawning
  local windows_after=$(hyprctl clients -j)
  local count_after=$(echo "$windows_after" | jq 'length')

  local new_addr=""

  if [ "$count_after" -gt "$count_before" ]; then
    # Find the new window by comparing before/after lists
    new_addr=$(comm -13 \
      <(echo "$windows_before" | jq -r '.[].address' | sort) \
      <(echo "$windows_after" | jq -r '.[].address' | sort) |
      head -1)
  fi

  # Fallback: try to find by the most recently mapped window
  if [ -z "$new_addr" ] || [ "$new_addr" = "null" ]; then
    new_addr=$(hyprctl clients -j | jq -r 'sort_by(.focusHistoryID) | .[-1] | .address')
  fi

  if [ -n "$new_addr" ] && [ "$new_addr" != "null" ]; then
    # Store the address and monitor name
    echo "$new_addr $monitor_name" >"$ADDR_FILE"
    debug_echo "Terminal created with address: $new_addr in special workspace on monitor $monitor_name"

    # Small delay to ensure it's properly in special workspace
    sleep 0.2

    # Now bring it back with the same animation as subsequent shows
    # Use movetoworkspacesilent to avoid affecting workspace history
    hyprctl dispatch movetoworkspacesilent "$CURRENT_WS,address:$new_addr"
    hyprctl dispatch pin "address:$new_addr"
    animate_fade_in "$new_addr" "$target_x" "$target_y" "$width" "$height"

    return 0
  fi

  debug_echo "Failed to get terminal address"
  return 1
}

# Main logic
# Handle reposition-only request (for gap changes)
if [ "$REPOSITION_ONLY" = "true" ] && terminal_exists; then
  TERMINAL_ADDR=$(get_terminal_address)
  debug_echo "Repositioning terminal for gap change: $TERMINAL_ADDR"

  # Calculate new position with current gaps
  pos_info=$(calculate_dropdown_position)
  target_x=$(echo $pos_info | cut -d' ' -f1)
  target_y=$(echo $pos_info | cut -d' ' -f2)
  width=$(echo $pos_info | cut -d' ' -f3)
  height=$(echo $pos_info | cut -d' ' -f4)

  # Only move if terminal is visible (not in special workspace)
  if ! terminal_in_special; then
    hyprctl dispatch movewindowpixel "exact $target_x $target_y,address:$TERMINAL_ADDR" >/dev/null 2>&1
    hyprctl dispatch resizewindowpixel "exact $width $height,address:$TERMINAL_ADDR" >/dev/null 2>&1
    debug_echo "Terminal repositioned to $target_x,$target_y (${width}x${height})"
  fi
  exit 0
fi

# Regular toggle logic
if terminal_exists; then
  TERMINAL_ADDR=$(get_terminal_address)
  debug_echo "Found existing terminal: $TERMINAL_ADDR"
  focused_monitor=$(get_monitor_info | awk '{print $6}')
  dropdown_monitor=$(get_terminal_monitor)
  if [ "$focused_monitor" != "$dropdown_monitor" ]; then
    debug_echo "Monitor focus changed: moving dropdown to $focused_monitor"
    # Calculate new position for focused monitor
    pos_info=$(calculate_dropdown_position)
    target_x=$(echo $pos_info | cut -d' ' -f1)
    target_y=$(echo $pos_info | cut -d' ' -f2)
    width=$(echo $pos_info | cut -d' ' -f3)
    height=$(echo $pos_info | cut -d' ' -f4)
    monitor_name=$(echo $pos_info | cut -d' ' -f5)
    # Move and resize window
    hyprctl dispatch movewindowpixel "exact $target_x $target_y,address:$TERMINAL_ADDR"
    hyprctl dispatch resizewindowpixel "exact $width $height,address:$TERMINAL_ADDR"
    # Update ADDR_FILE
    echo "$TERMINAL_ADDR $monitor_name" >"$ADDR_FILE"
  fi

  if terminal_in_special; then
    debug_echo "Bringing terminal from scratchpad with slide down animation"

    # Calculate target position
    pos_info=$(calculate_dropdown_position)
    target_x=$(echo $pos_info | cut -d' ' -f1)
    target_y=$(echo $pos_info | cut -d' ' -f2)
    width=$(echo $pos_info | cut -d' ' -f3)
    height=$(echo $pos_info | cut -d' ' -f4)

    # Use movetoworkspacesilent to avoid affecting workspace history
    hyprctl dispatch movetoworkspacesilent "$CURRENT_WS,address:$TERMINAL_ADDR"
    hyprctl dispatch pin "address:$TERMINAL_ADDR"

    # Set size and animate slide down
    hyprctl dispatch resizewindowpixel "exact $width $height,address:$TERMINAL_ADDR"
    animate_fade_in "$TERMINAL_ADDR" "$target_x" "$target_y" "$width" "$height"

    hyprctl dispatch focuswindow "address:$TERMINAL_ADDR"
  else
    debug_echo "Hiding terminal to scratchpad with slide up animation"

    # Get current geometry for animation
    geometry=$(get_window_geometry "$TERMINAL_ADDR")
    if [ -n "$geometry" ]; then
      curr_x=$(echo $geometry | cut -d' ' -f1)
      curr_y=$(echo $geometry | cut -d' ' -f2)
      curr_width=$(echo $geometry | cut -d' ' -f3)
      curr_height=$(echo $geometry | cut -d' ' -f4)

      debug_echo "Current geometry: ${curr_x},${curr_y} ${curr_width}x${curr_height}"

      # Animate fade out first
      animate_fade_out "$TERMINAL_ADDR"

      # Small delay then move to special workspace and unpin
      sleep 0.1
      hyprctl dispatch pin "address:$TERMINAL_ADDR" # Unpin (toggle)
      hyprctl dispatch movetoworkspacesilent "$SPECIAL_WS,address:$TERMINAL_ADDR"
    else
      debug_echo "Could not get window geometry, moving to scratchpad without animation"
      hyprctl dispatch pin "address:$TERMINAL_ADDR"
      hyprctl dispatch movetoworkspacesilent "$SPECIAL_WS,address:$TERMINAL_ADDR"
    fi
  fi
else
  debug_echo "No existing terminal found, creating new one"
  if spawn_terminal; then
    TERMINAL_ADDR=$(get_terminal_address)
    if [ -n "$TERMINAL_ADDR" ]; then
      hyprctl dispatch focuswindow "address:$TERMINAL_ADDR"
    fi
  fi
fi
