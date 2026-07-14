#!/usr/bin/env bash
# Entry point for the window switcher (SUPER+CTRL+S).
# Uses TermPopup.sh to spawn a floating kitty running WindowSwitcher.sh.

SCRIPTS="$HOME/.config/hypr/scripts"

exec "$SCRIPTS/TermPopup.sh" \
  --class HyprWinSwitch \
  --title "Window Switcher" \
  -- "$SCRIPTS/WindowSwitcher.sh"
