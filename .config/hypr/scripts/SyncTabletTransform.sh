#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
# Sync tablet transform with monitor profile
#
# Integration (Phase 1):
# - Removed from Startup_Apps.conf (was inefficient, only ran once at boot)
# - Integrated into MonitorProfiles.sh (runs when user changes monitor profile)
# - Checks monitors.conf for 270° or 90° rotation and sets tablet transform accordingly
#
# Usage: Called automatically from MonitorProfiles.sh after profile loads
# Manual: $HOME/.config/hypr/scripts/SyncTabletTransform.sh

monitors_conf="$HOME/.config/hypr/monitors.conf"

# Check if monitors.conf contains 270° transform (transform, 3) or 90° transform (transform, 1)
# When monitor is rotated 270° or 90°, set tablet to 90° rotation (transform = 1)
# Otherwise, set tablet to normal (transform = 0)
if grep -qE "(transform.*[[:space:]]*3|#.*270)" "$monitors_conf" 2>/dev/null || grep -qE "(transform.*[[:space:]]*1|#.*rotated.*90)" "$monitors_conf" 2>/dev/null; then
    hyprctl keyword input:tablet:transform 1
else
    hyprctl keyword input:tablet:transform 0
fi
