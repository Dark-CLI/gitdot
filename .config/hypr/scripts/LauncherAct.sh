#!/usr/bin/env bash
# Dispatch a selected launcher row.
# Usage: LauncherAct.sh <type> <payload>
#   app  → spawn the desktop Exec line
#   dir  → kitty in <payload>, attach/create tmux session named after the dir
#   cmd  → run the shell command

set -u

type="${1:-}"
payload="${2:-}"

[[ -z "$type" || -z "$payload" ]] && exit 0

# Single-quote escape for embedding into sh -c '...' inside [[ ]].
esc_sq() { printf %s "$1" | sed "s/'/'\\\\''/g"; }

# Centered popup geometry matching Launcher.sh (52% × 60% of focused monitor).
launcher_geometry() {
  read -r MX MY MW MH < <(hyprctl monitors -j 2>/dev/null |
    jq -r '.[] | select(.focused == true) | "\(.x) \(.y) \(.width) \(.height)"')
  [ -z "$MW" ] && MW=2560; [ -z "$MH" ] && MH=1440
  [ -z "$MX" ] && MX=0;    [ -z "$MY" ] && MY=0
  GW=$((MW * 52 / 100))
  GH=$((MH * 60 / 100))
  GX=$((MX + (MW - GW) / 2))
  GY=$((MY + (MH - GH) / 2))
}

case "$type" in
  app|cmd)
    # Hand off to Hyprland's exec_cmd so the spawned process is
    # parented to Hyprland — survives the launcher kitty closing.
    # Lua long-string [[ ]] avoids escaping inside the payload.
    hyprctl dispatch "hl.dsp.exec_cmd([[sh -c '$(esc_sq "$payload")']])" >/dev/null
    ;;
  term-app)
    # Desktop entry has Terminal=true (htop, vim, …). Open a kitty
    # window with the command; same Hyprland-parented dispatch.
    hyprctl dispatch "hl.dsp.exec_cmd([[kitty -- sh -c '$(esc_sq "$payload")']])" >/dev/null
    ;;
  dir)
    name=$(basename "$payload" | tr -c 'A-Za-z0-9_-' '_' | cut -c1-32)
    [[ -z "$name" ]] && name="launcher"
    # Open the kitty + tmux session as a floating popup at the same
    # geometry as the launcher itself, so it lands centered on top of
    # where the launcher just was.
    launcher_geometry
    hyprctl dispatch \
      "hl.dsp.exec_cmd([[kitty --class HyprLauncherDir --title '$name' --working-directory '$payload' -- tmux new-session -A -s $name]], { float = true, size = \"$GW $GH\", move = \"$GX $GY\" })" \
      >/dev/null
    ;;
  root-app|root-cmd)
    # GUI / non-tty path: pkexec → hyprpolkitagent shows the auth
    # dialog (with the full command in the details, but it works
    # zero-setup on any system the dotfiles land on).
    PK_ENV="env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-} DISPLAY=${DISPLAY:-} XAUTHORITY=${XAUTHORITY:-}"
    hyprctl dispatch \
      "hl.dsp.exec_cmd([[pkexec $PK_ENV sh -c '$(esc_sq "$payload")']])" \
      >/dev/null
    ;;
  root-term-app)
    # TUI as root: needs a terminal to draw and for sudo to read the
    # password. Spawn at the same geometry as the launcher popup.
    launcher_geometry
    hyprctl dispatch \
      "hl.dsp.exec_cmd([[kitty --class HyprLauncherRoot --title 'Launcher (root)' -- sudo -E bash -c '$(esc_sq "$payload")']], { float = true, size = \"$GW $GH\", move = \"$GX $GY\" })" \
      >/dev/null
    ;;
  root-dir)
    # Root shell in the chosen directory; popup at launcher geometry.
    launcher_geometry
    hyprctl dispatch \
      "hl.dsp.exec_cmd([[kitty --class HyprLauncherRoot --title 'Launcher (root)' --working-directory '$payload' -- sudo -i]], { float = true, size = \"$GW $GH\", move = \"$GX $GY\" })" \
      >/dev/null
    ;;
  power)
    # Power actions, same commands as scripts/Wlogout.sh.
    case "$payload" in
      lock)     hyprctl dispatch "hl.dsp.exec_cmd([[$HOME/.config/hypr/scripts/LockScreen.sh]])" >/dev/null ;;
      blank)    hyprctl dispatch "hl.dsp.exec_cmd([[$HOME/.config/hypr/scripts/BlankScreen.sh]])" >/dev/null ;;
      logout)   hyprctl dispatch "hl.dsp.exec_cmd([[loginctl terminate-session $XDG_SESSION_ID]])" >/dev/null ;;
      suspend)  hyprctl dispatch "hl.dsp.exec_cmd([[systemctl suspend]])" >/dev/null ;;
      reboot)   hyprctl dispatch "hl.dsp.exec_cmd([[systemctl reboot]])" >/dev/null ;;
      shutdown) hyprctl dispatch "hl.dsp.exec_cmd([[systemctl poweroff]])" >/dev/null ;;
    esac
    ;;
esac
