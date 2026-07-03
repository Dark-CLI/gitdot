#!/bin/bash
# Handle fullscreen for both floating and tiling windows
# If the window is floating, toggle it to tiling first, then apply fullscreen

# Log for debugging
echo "Fullscreen handler called at $(date)" >> /tmp/hypr_fullscreen.log

# Get the active window info
WINDOW_INFO=$(hyprctl activewindow -j)
IS_FLOATING=$(echo "$WINDOW_INFO" | jq -r '.floating')

echo "Window floating status: $IS_FLOATING" >> /tmp/hypr_fullscreen.log

# If floating, toggle to tiling first
if [ "$IS_FLOATING" = "true" ]; then
    echo "Window is floating, toggling to tiling" >> /tmp/hypr_fullscreen.log
    hyprctl dispatch togglefloating
    sleep 0.2
fi

# Apply fullscreen
echo "Applying fullscreen" >> /tmp/hypr_fullscreen.log
hyprctl dispatch fullscreen 1
