#!/usr/bin/env bash
# Entry point for the animation-preset picker (SUPER+SHIFT+A).
# Uses TermPopup.sh to spawn a floating kitty running Animations.sh.

SCRIPTS="$HOME/.config/hypr/scripts"

exec "$SCRIPTS/TermPopup.sh" \
  --class HyprAnimations \
  --title Animations \
  -- "$SCRIPTS/Animations.sh"
