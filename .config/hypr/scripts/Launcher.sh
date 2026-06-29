#!/usr/bin/env bash
# Entry point for the terminal-based launcher (SUPER+SHIFT+D).
# Single-instance: focus the existing popup if open. Otherwise spawn a
# kitty floating window centered on the focused monitor and run
# LauncherInner.sh inside it.
#
# Modes (live-switched via prefix; see LauncherRouter.sh):
#   (empty)  → apps
#   /...     → directories under $HOME
#   >...     → command history + run-literal

SCRIPTS="$HOME/.config/hypr/scripts"

# Already open? Focus it instead of spawning a second one.
EXISTING=$(hyprctl clients -j 2>/dev/null | jq -r '.[] | select(.class == "HyprLauncher") | .address' | head -1)
if [ -n "$EXISTING" ]; then
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$EXISTING\" })" >/dev/null 2>&1
  exit 0
fi

# Center on the focused monitor; ~52% × 60% of its area.
read -r MX MY MW MH < <(hyprctl monitors -j 2>/dev/null |
  jq -r '.[] | select(.focused == true) | "\(.x) \(.y) \(.width) \(.height)"')
[ -z "$MW" ] && MW=2560
[ -z "$MH" ] && MH=1440
[ -z "$MX" ] && MX=0
[ -z "$MY" ] && MY=0
W=$((MW * 52 / 100))
H=$((MH * 60 / 100))
X=$((MX + (MW - W) / 2))
Y=$((MY + (MH - H) / 2))

hyprctl dispatch \
  "hl.dsp.exec_cmd(\"kitty --class HyprLauncher --title 'Launcher' -- $SCRIPTS/LauncherInner.sh\", { float = true, size = \"$W $H\", move = \"$X $Y\" })" \
  >/dev/null 2>&1
