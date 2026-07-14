#!/usr/bin/env bash
# Terminal power menu. Runs inside the HyprWlogout kitty popup (see
# WlogoutLaunch.sh). Same options the launcher's `!` prefix offers.
#
# Enter        → run the highlighted action
# Esc          → cancel

set -u

chosen=$(
  printf '%s\n' Lock 'Blank screen' Logout Suspend Reboot Shutdown |
    fzf \
      --prompt='> ' \
      --pointer='▶' \
      --marker='*' \
      --info=inline \
      --no-mouse \
      --reverse \
      --tiebreak=index \
      --bind 'esc:abort' \
      --header='Power menu'
)

[[ -z "$chosen" ]] && exit 0

# Dispatch through Hyprland so the action outlives this popup.
dispatch() { hyprctl dispatch "hl.dsp.exec_cmd([[$1]])" >/dev/null 2>&1; }

case "$chosen" in
  Logout)         dispatch "loginctl terminate-session $XDG_SESSION_ID" ;;
  Lock)           dispatch "$HOME/.config/hypr/scripts/LockScreen.sh" ;;
  "Blank screen") dispatch "$HOME/.config/hypr/scripts/BlankScreen.sh" ;;
  Suspend)        dispatch "systemctl suspend" ;;
  Reboot)         dispatch "systemctl reboot" ;;
  Shutdown)       dispatch "systemctl poweroff" ;;
esac
