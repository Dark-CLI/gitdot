#!/usr/bin/env bash
# Entry point for the terminal power menu (CTRL+ALT+P).
# Uses TermPopup.sh to spawn a floating kitty running Wlogout.sh.

SCRIPTS="$HOME/.config/hypr/scripts"

exec "$SCRIPTS/TermPopup.sh" \
  --class HyprWlogout \
  --title "Power Menu" \
  -- "$SCRIPTS/Wlogout.sh"
