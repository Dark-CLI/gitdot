#!/usr/bin/env bash
# Entry point for the wallpaper effects picker (SUPER+SHIFT+W).
# Uses TermPopup.sh to spawn a floating kitty running WallpaperEffects.sh.

SCRIPTS="$HOME/.config/hypr/scripts"

exec "$SCRIPTS/TermPopup.sh" \
  --class HyprWallpaperEffects \
  --title "Wallpaper Effects" \
  -- "$HOME/.config/hypr/UserScripts/WallpaperEffects.sh"
