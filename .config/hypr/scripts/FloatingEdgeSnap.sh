#!/usr/bin/env bash
# Move a floating window in one of two modes (toggled via
# FloatingMoveMode.sh, state in /tmp/hypr-float-move-mode):
#
#   snap  - slam the window's edge to the matching side of the monitor's
#           usable area (monitor minus reserved bar space, minus gaps_out).
#           Default if the state file is missing.
#   step  - nudge the window by STEP pixels per keypress in the given
#           direction, clamped to the same usable area.
#
# Tiled windows always delegate to Hyprland's built-in direction move
# regardless of mode.
#
# Invoked async from lua/binds/custom.lua via hl.exec_cmd, so this runs
# in its own process and never blocks the Hyprland main thread.
#
# Usage:  FloatingEdgeSnap.sh l|r|u|d

set -eu

dir="${1:-}"
[[ "$dir" =~ ^[lrud]$ ]] || { echo "bad direction: $dir" >&2; exit 1; }

STEP=80
STATE=/tmp/hypr-float-move-mode
mode=$(cat "$STATE" 2>/dev/null)
[[ "$mode" != "step" ]] && mode=snap

read -r floating monitor wx wy ww wh < <(
  hyprctl activewindow -j 2>/dev/null |
    jq -r '"\(.floating) \(.monitor) \(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])"'
)

# Tiled windows: delegate to Hyprland's built-in direction move.
if [[ "$floating" != "true" ]]; then
  hyprctl dispatch "hl.dsp.window.move({ direction = \"$dir\" })" >/dev/null
  exit 0
fi

# Monitor geometry + reserved [left, top, right, bottom]
read -r mx my mw mh rl rt rr rb < <(
  hyprctl monitors -j 2>/dev/null |
    jq -r --argjson id "$monitor" '
      .[] | select(.id == $id) |
      "\(.x) \(.y) \(.width) \(.height) \(.reserved[0]) \(.reserved[1]) \(.reserved[2]) \(.reserved[3])"
    '
)

# gaps_out returns { "css": "T R B L" } (a CssGap string of four ints).
# Take the first value — gap_control.lua does the same (top/left fallback).
gap_raw=$(hyprctl getoption general:gaps_out -j 2>/dev/null | jq -r '.css // ""')
g=$(awk '{ print $1 + 0 }' <<<"$gap_raw")

min_x=$(( mx + rl + g ))
min_y=$(( my + rt + g ))
max_x=$(( mx + mw - rr - ww - g ))
max_y=$(( my + mh - rb - wh - g ))

if [[ "$mode" == "snap" ]]; then
  nx="$wx"; ny="$wy"
  case "$dir" in
    l) nx="$min_x" ;;
    r) nx="$max_x" ;;
    u) ny="$min_y" ;;
    d) ny="$max_y" ;;
  esac
else
  # step mode: nudge by STEP pixels, clamp to the usable area
  dx=0; dy=0
  case "$dir" in
    l) dx=-$STEP ;;
    r) dx=$STEP ;;
    u) dy=-$STEP ;;
    d) dy=$STEP ;;
  esac
  nx=$(( wx + dx )); ny=$(( wy + dy ))
  (( nx < min_x )) && nx=$min_x
  (( ny < min_y )) && ny=$min_y
  (( nx > max_x )) && nx=$max_x
  (( ny > max_y )) && ny=$max_y
fi

hyprctl dispatch "hl.dsp.window.move({ x = $nx, y = $ny })" >/dev/null
