#!/usr/bin/env bash
# Toggle the floating-window move mode used by FloatingEdgeSnap.sh.
# Modes:
#   snap  - one keypress slams the window edge to the matching side of
#           the monitor's usable area (default)
#   step  - one keypress nudges the window by a fixed pixel offset
#
# State lives in /tmp/hypr-float-move-mode (one of the two strings above).
# Missing or unreadable file = snap.

STATE=/tmp/hypr-float-move-mode

current=$(cat "$STATE" 2>/dev/null)
[[ "$current" != "step" ]] && current=snap

if [[ "$current" == "snap" ]]; then
  new=step
else
  new=snap
fi
printf '%s' "$new" >"$STATE"

notify-send -e -t 1200 \
  -h "string:x-canonical-private-synchronous:float_move_mode" \
  -h "boolean:SWAYNC_BYPASS_DND:true" \
  -u low \
  "Floating Move Mode" "$new"
