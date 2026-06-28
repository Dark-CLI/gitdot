#!/usr/bin/env bash
# Edge-snap a floating window to one side of the monitor's usable area
# (monitor size minus the layer-shell reserved region, minus gaps_out).
# Invoked async from lua/binds/custom.lua via hl.exec_cmd, so this runs
# in its own process and never blocks the Hyprland main thread.
#
# Usage:  FloatingEdgeSnap.sh l|r|u|d

set -eu

dir="${1:-}"
[[ "$dir" =~ ^[lrud]$ ]] || { echo "bad direction: $dir" >&2; exit 1; }

read -r floating monitor wx wy ww wh < <(
  hyprctl activewindow -j 2>/dev/null |
    jq -r '"\(.floating) \(.monitor) \(.at[0]) \(.at[1]) \(.size[0]) \(.size[1])"'
)

# Tiled windows: delegate to Hyprland's built-in direction move.
if [[ "$floating" != "true" ]]; then
  case "$dir" in
    l) dispatch_dir="l" ;;
    r) dispatch_dir="r" ;;
    u) dispatch_dir="u" ;;
    d) dispatch_dir="d" ;;
  esac
  hyprctl dispatch "hl.dsp.window.move({ direction = \"$dispatch_dir\" })" >/dev/null
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

nx="$wx"; ny="$wy"
case "$dir" in
  l) nx="$min_x" ;;
  r) nx="$max_x" ;;
  u) ny="$min_y" ;;
  d) ny="$max_y" ;;
esac

hyprctl dispatch "hl.dsp.window.move({ x = $nx, y = $ny })" >/dev/null
