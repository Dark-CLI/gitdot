#!/bin/bash
# Get the currently configured terminal from Hyprland config
# This ensures all scripts use the same terminal regardless of individual configs

# Read from Hyprland's active config
hyprctl getoption '$term' -j 2>/dev/null | jq -r '.str' || echo "kitty"
