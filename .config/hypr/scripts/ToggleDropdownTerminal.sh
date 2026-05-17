#!/bin/bash
# Toggle only the Dropdown Terminal window
# Moves window between current workspace (visible) and workspace 99 (hidden)

STATE_FILE="/tmp/dropdown_terminal_state"

# Get the window address by title
ADDR=$(hyprctl clients -j | jq -r '.[] | select(.title=="Dropdown Terminal") | .address' | head -1)

if [ -z "$ADDR" ]; then
    # Window doesn't exist, create it on current workspace
    CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')
    alacritty --title "Dropdown Terminal" > /dev/null 2>&1 &
    sleep 0.5
    # Move to current workspace (should already be there, but just in case)
    hyprctl dispatch movetoworkspacesilent "$CURRENT_WS","address:$(hyprctl clients -j | jq -r '.[] | select(.title=="Dropdown Terminal") | .address' | head -1)" 2>/dev/null
    echo "shown" > "$STATE_FILE"
else
    # Window exists, toggle its visibility
    CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "shown")

    if [ "$CURRENT_STATE" == "shown" ]; then
        # Hide the window by moving to workspace 99
        hyprctl dispatch movetoworkspacesilent 99,"address:$ADDR"
        echo "hidden" > "$STATE_FILE"
    else
        # Show the window on current workspace
        CURRENT_WS=$(hyprctl activeworkspace -j | jq -r '.id')
        hyprctl dispatch movetoworkspacesilent "$CURRENT_WS","address:$ADDR"
        hyprctl dispatch focuswindow "address:$ADDR"
        echo "shown" > "$STATE_FILE"
    fi
fi
