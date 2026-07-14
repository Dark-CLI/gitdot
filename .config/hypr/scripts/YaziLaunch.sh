#!/usr/bin/env bash
# Entry point for the yazi file browser (SUPER+E).
# Uses TermPopup.sh to spawn a floating kitty running yazi.

SCRIPTS="$HOME/.config/hypr/scripts"

exec "$SCRIPTS/TermPopup.sh" \
  --class HyprYazi \
  --title Files \
  -- yazi
