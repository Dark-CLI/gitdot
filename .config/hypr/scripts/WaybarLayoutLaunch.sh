#!/usr/bin/env bash
# Entry point for the waybar layout picker (SUPER+ALT+B).
# Uses TermPopup.sh to spawn a floating kitty running WaybarLayout.sh.

SCRIPTS="$HOME/.config/hypr/scripts"

exec "$SCRIPTS/TermPopup.sh" \
  --class HyprWaybarLayout \
  --title "Waybar Layout" \
  -- "$SCRIPTS/WaybarLayout.sh"
