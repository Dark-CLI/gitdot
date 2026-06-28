#!/usr/bin/env bash
# Async volume notification — meant to run in the background after the
# wpctl set-volume call has already returned. Reads current volume / mute
# state from wpctl, fires a single notify-send with replace-id so the
# popups don't queue when the key auto-repeats.
#
# Invoked by the volume keybinds; not on the critical path of the volume
# change itself.

iDIR="$HOME/.config/swaync/icons"

case "$1" in
  mic) NODE="@DEFAULT_AUDIO_SOURCE@" ;;
  *)   NODE="@DEFAULT_AUDIO_SINK@" ;;
esac

read -r _ raw muted < <(wpctl get-volume "$NODE" 2>/dev/null)
pct=$(awk -v v="$raw" 'BEGIN { printf "%d", v * 100 + 0.5 }')

if [[ "$1" == "mic" ]]; then
  if [[ "$muted" == "[MUTED]" ]]; then
    icon="$iDIR/microphone-mute.png"
    title=" Microphone"
    body="Muted"
  else
    icon="$iDIR/microphone.png"
    title=" Mic Level"
    body="$pct %"
  fi
else
  if [[ "$muted" == "[MUTED]" ]]; then
    icon="$iDIR/volume-mute.png"
    title=" Volume"
    body="Muted"
  elif (( pct <= 30 )); then
    icon="$iDIR/volume-low.png"
    title=" Volume Level"
    body="$pct %"
  elif (( pct <= 60 )); then
    icon="$iDIR/volume-mid.png"
    title=" Volume Level"
    body="$pct %"
  else
    icon="$iDIR/volume-high.png"
    title=" Volume Level"
    body="$pct %"
  fi
fi

notify-send -e -t 1200 \
  -h "string:x-canonical-private-synchronous:volume_notif" \
  -h "boolean:SWAYNC_BYPASS_DND:true" \
  -h "int:value:$pct" \
  -u low -i "$icon" "$title" "$body"
