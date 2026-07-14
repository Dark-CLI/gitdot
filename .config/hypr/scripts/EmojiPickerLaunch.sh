#!/usr/bin/env bash
# Entry point for the emoji picker (SUPER+ALT+E).
# Uses TermPopup.sh to spawn a floating kitty running EmojiPicker.sh.

SCRIPTS="$HOME/.config/hypr/scripts"

exec "$SCRIPTS/TermPopup.sh" \
  --class HyprEmoji \
  --title Emoji \
  -- "$SCRIPTS/EmojiPicker.sh"
