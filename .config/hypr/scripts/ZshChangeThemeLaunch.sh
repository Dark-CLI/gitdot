#!/usr/bin/env bash
# Entry point for the Oh My Zsh theme picker (SUPER+SHIFT+O).
# Uses TermPopup.sh to spawn a floating kitty running ZshChangeTheme.sh.

SCRIPTS="$HOME/.config/hypr/scripts"

exec "$SCRIPTS/TermPopup.sh" \
  --class HyprZshTheme \
  --title "Oh My Zsh Theme" \
  -- "$HOME/.config/hypr/UserScripts/ZshChangeTheme.sh"
