#!/usr/bin/env bash
# Entry point for the KooL Quick Settings hub (SUPER+SHIFT+E).
# Uses TermPopup.sh to spawn a floating kitty running Kool_Quick_Settings.sh.

SCRIPTS="$HOME/.config/hypr/scripts"

exec "$SCRIPTS/TermPopup.sh" \
  --class HyprKoolQS \
  --title "KooL Quick Settings" \
  -- "$SCRIPTS/Kool_Quick_Settings.sh"
