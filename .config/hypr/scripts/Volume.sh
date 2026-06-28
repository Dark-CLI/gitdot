#!/usr/bin/env bash
# Volume / mic controls using wpctl (PipeWire-native).
# Replaces the original pamixer-based script, which fails with
# "Connection error" against pipewire-pulse on Fedora 44.
# Same CLI: --inc / --dec / --inc-precise / --dec-precise / --toggle /
# --toggle-mic / --mic-inc / --mic-dec / --get / --get-icon / --get-mic-icon

iDIR="$HOME/.config/swaync/icons"
sDIR="$HOME/.config/hypr/scripts"

SINK="@DEFAULT_AUDIO_SINK@"
SOURCE="@DEFAULT_AUDIO_SOURCE@"

# --- volume helpers ---------------------------------------------------------
# wpctl get-volume prints "Volume: 0.50" or "Volume: 0.50 [MUTED]"
# Convert the 0.50 to integer percent.
_vol_pct() {
  local line pct
  line=$(wpctl get-volume "$1" 2>/dev/null) || return 1
  pct=$(awk '{ printf "%d", ($2 * 100) + 0.5 }' <<<"$line")
  echo "$pct"
}

_is_muted() {
  wpctl get-volume "$1" 2>/dev/null | grep -q '\[MUTED\]'
}

get_volume() {
  if _is_muted "$SINK"; then
    echo "Muted"
  else
    echo "$(_vol_pct "$SINK") %"
  fi
}

get_mic_volume() {
  if _is_muted "$SOURCE"; then
    echo "Muted"
  else
    echo "$(_vol_pct "$SOURCE") %"
  fi
}

# --- icons ------------------------------------------------------------------
get_icon() {
  local current
  current=$(get_volume)
  if [[ "$current" == "Muted" ]]; then
    echo "$iDIR/volume-mute.png"
  elif [[ "${current%\ %}" -le 30 ]]; then
    echo "$iDIR/volume-low.png"
  elif [[ "${current%\ %}" -le 60 ]]; then
    echo "$iDIR/volume-mid.png"
  else
    echo "$iDIR/volume-high.png"
  fi
}

get_mic_icon() {
  if _is_muted "$SOURCE"; then
    echo "$iDIR/microphone-mute.png"
  else
    echo "$iDIR/microphone.png"
  fi
}

# --- notifications ---------------------------------------------------------
notify_user() {
  if [[ "$(get_volume)" == "Muted" ]]; then
    notify-send -e -h string:x-canonical-private-synchronous:volume_notif \
      -h boolean:SWAYNC_BYPASS_DND:true -u low -i "$(get_icon)" \
      " Volume:" " Muted"
  else
    notify-send -e -h int:value:"$(_vol_pct "$SINK")" \
      -h string:x-canonical-private-synchronous:volume_notif \
      -h boolean:SWAYNC_BYPASS_DND:true -u low -i "$(get_icon)" \
      " Volume Level:" " $(get_volume)" &&
      "$sDIR/Sounds.sh" --volume
  fi
}

notify_mic_user() {
  local volume icon
  volume=$(get_mic_volume)
  icon=$(get_mic_icon)
  notify-send -e -h int:value:"$(_vol_pct "$SOURCE")" \
    -h string:x-canonical-private-synchronous:volume_notif \
    -h boolean:SWAYNC_BYPASS_DND:true -u low -i "$icon" \
    " Mic Level:" " $volume"
}

# --- volume actions ---------------------------------------------------------
# wpctl limits the maximum at MAX_VOLUME (default 1.0 = 100%). The third
# positional arg overrides that cap; 1.5 matches the original pamixer
# --set-limit 150 behaviour.
inc_volume() {
  if _is_muted "$SINK"; then
    toggle_mute
    return
  fi
  wpctl set-volume -l 1.5 "$SINK" 5%+ && notify_user &
}

dec_volume() {
  if _is_muted "$SINK"; then
    toggle_mute
    return
  fi
  wpctl set-volume "$SINK" 5%- && notify_user &
}

inc_volume_precise() {
  if _is_muted "$SINK"; then
    toggle_mute
    return
  fi
  wpctl set-volume -l 1.5 "$SINK" 1%+ && notify_user &
}

dec_volume_precise() {
  if _is_muted "$SINK"; then
    toggle_mute
    return
  fi
  wpctl set-volume "$SINK" 1%- && notify_user &
}

toggle_mute() {
  wpctl set-mute "$SINK" toggle
  if _is_muted "$SINK"; then
    notify-send -e -u low -h boolean:SWAYNC_BYPASS_DND:true \
      -i "$iDIR/volume-mute.png" " Mute"
  else
    notify-send -e -u low -h boolean:SWAYNC_BYPASS_DND:true \
      -i "$(get_icon)" " Volume:" " Switched ON"
  fi
}

# --- mic actions -----------------------------------------------------------
toggle_mic() {
  wpctl set-mute "$SOURCE" toggle
  if _is_muted "$SOURCE"; then
    notify-send -e -u low -h boolean:SWAYNC_BYPASS_DND:true \
      -i "$iDIR/microphone-mute.png" " Microphone:" " Switched OFF"
  else
    notify-send -e -u low -h boolean:SWAYNC_BYPASS_DND:true \
      -i "$iDIR/microphone.png" " Microphone:" " Switched ON"
  fi
}

inc_mic_volume() {
  if _is_muted "$SOURCE"; then
    toggle_mic
  else
    wpctl set-volume "$SOURCE" 5%+ && notify_mic_user
  fi
}

dec_mic_volume() {
  if _is_muted "$SOURCE"; then
    toggle_mic
  else
    wpctl set-volume "$SOURCE" 5%- && notify_mic_user
  fi
}

# --- dispatch --------------------------------------------------------------
case "$1" in
  --get)            get_volume ;;
  --inc)            inc_volume ;;
  --dec)            dec_volume ;;
  --inc-precise)    inc_volume_precise ;;
  --dec-precise)    dec_volume_precise ;;
  --toggle)         toggle_mute ;;
  --toggle-mic)     toggle_mic ;;
  --get-icon)       get_icon ;;
  --get-mic-icon)   get_mic_icon ;;
  --mic-inc)        inc_mic_volume ;;
  --mic-dec)        dec_mic_volume ;;
  *)                get_volume ;;
esac
