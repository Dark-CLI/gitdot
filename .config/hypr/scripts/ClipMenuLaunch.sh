#!/usr/bin/env bash
# Entry point for the clipboard picker (SUPER+V).
# Uses TermPopup.sh to spawn a floating kitty running ClipMenu.sh.

SCRIPTS="$HOME/.config/hypr/scripts"

exec "$SCRIPTS/TermPopup.sh" \
  --class HyprClipMenu \
  --title Clipboard \
  -- "$SCRIPTS/ClipMenu.sh"
