#!/usr/bin/env bash
# Entry point for the waybar style picker (SUPER+CTRL+B).
# Uses TermPopup.sh to spawn a floating kitty running WaybarStyles.sh.

SCRIPTS="$HOME/.config/hypr/scripts"

exec "$SCRIPTS/TermPopup.sh" \
  --class HyprWaybarStyles \
  --title "Waybar Style" \
  -- "$SCRIPTS/WaybarStyles.sh"
