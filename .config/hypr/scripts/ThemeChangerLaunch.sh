#!/usr/bin/env bash
# Entry point for the wallust global theme picker (SUPER+T).
# Uses TermPopup.sh to spawn a floating kitty running ThemeChanger.sh.

SCRIPTS="$HOME/.config/hypr/scripts"

exec "$SCRIPTS/TermPopup.sh" \
  --class HyprThemeChanger \
  --title "Theme Changer" \
  -- "$SCRIPTS/ThemeChanger.sh"
