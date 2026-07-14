#!/usr/bin/env bash
# Entry point for the terminal-based launcher (SUPER+D).
# Single-instance, floating, centered kitty popup running LauncherInner.sh.
# Window plumbing lives in TermPopup.sh.
#
# Modes (live-switched via prefix; see LauncherRouter.sh):
#   (empty)  → apps
#   /...     → directories under $HOME
#   >...     → command history + run-literal
#   !...     → power actions

SCRIPTS="$HOME/.config/hypr/scripts"

exec "$SCRIPTS/TermPopup.sh" \
  --class HyprLauncher \
  --title Launcher \
  -- "$SCRIPTS/LauncherInner.sh"
