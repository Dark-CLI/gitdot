#!/usr/bin/env bash
# Dispatch a selected launcher row.
# Usage: LauncherAct.sh <type> <payload>
#   app  → spawn the desktop Exec line
#   dir  → kitty in <payload> (Herdr manages the pane)
#   cmd  → run the shell command

set -u

type="${1:-}"
payload="${2:-}"

[[ -z "$type" || -z "$payload" ]] && exit 0

# Single-quote escape for embedding into sh -c '...' inside [[ ]].
esc_sq() { printf %s "$1" | sed "s/'/'\\\\''/g"; }

# Get current workspace and set temporary workspace rule for slow-launching apps
# This ensures apps launched from workspace X open in X, even if they take time to start
set_temp_workspace_rule() {
  local workspace app_class="$1"
  [[ -z "$app_class" ]] && return

  # Get current workspace
  workspace=$(hyprctl activewindow -j 2>/dev/null | jq -r '.workspace.id' 2>/dev/null)
  [[ -z "$workspace" || "$workspace" == "null" ]] && return

  # Set temporary rule for this app class (applies for 30 seconds)
  hyprctl --batch "keyword windowrule 'workspace $workspace silent,$app_class'" >/dev/null 2>&1

  # Clean up rule after 30 seconds (app should have opened by then)
  (sleep 30; hyprctl keyword windowrule '' >/dev/null 2>&1) &
}

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
    # Extract app class name from payload (first word = binary name, usually the window class)
    app_class=$(echo "$payload" | awk '{print $1}' | xargs -I {} basename {} | sed 's/-$//')

    # Set temporary workspace rule before launching (handles slow-starting apps)
    set_temp_workspace_rule "$app_class"

    # Hand off to Hyprland's exec_cmd so the spawned process is
    # parented to Hyprland — survives the launcher kitty closing.
    # Lua long-string [[ ]] avoids escaping inside the payload.
    # Use exec to replace the shell with the app, preventing window class
    # from being inherited from the launcher.
    hyprctl dispatch "hl.dsp.exec_cmd([[sh -c 'exec $(esc_sq "$payload")']])" >/dev/null
    ;;
  term-app)
    # Extract app class from payload
    app_class=$(echo "$payload" | awk '{print $1}' | xargs -I {} basename {} | sed 's/-$//')

    # Set temporary workspace rule before launching
    set_temp_workspace_rule "$app_class"

    # Desktop entry has Terminal=true (htop, vim, …). Open a kitty
    # window with the command; same Hyprland-parented dispatch.
    # Use exec to replace the shell with the app.
    hyprctl dispatch "hl.dsp.exec_cmd([[kitty -- sh -c 'exec $(esc_sq "$payload")']])" >/dev/null
    ;;
  dir)
    name=$(basename "$payload" | tr -c 'A-Za-z0-9_-' '_' | cut -c1-32 | sed 's/_*$//')
    [[ -z "$name" ]] && name="launcher"
    launcher_geometry
    herdr workspace create --label "$name" --cwd "$payload" --focus >/dev/null 2>&1
    hyprctl dispatch \
      "hl.dsp.exec_cmd([[kitty --class HyprLauncherDir --title '$name' --working-directory '$payload']], { float = true, size = \"$GW $GH\", move = \"$GX $GY\" })" \
      >/dev/null
    ;;
  root-app|root-cmd)
    # GUI / non-tty path: pkexec → hyprpolkitagent shows the auth
    # dialog (with the full command in the details, but it works
    # zero-setup on any system the dotfiles land on).
    # Use exec to replace the shell with the app.
    PK_ENV="env XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-} DISPLAY=${DISPLAY:-} XAUTHORITY=${XAUTHORITY:-}"
    hyprctl dispatch \
      "hl.dsp.exec_cmd([[pkexec $PK_ENV sh -c 'exec $(esc_sq "$payload")']])" \
      >/dev/null
    ;;
  root-term-app)
    # TUI as root: needs a terminal to draw and for sudo to read the
    # password. Spawn at the same geometry as the launcher popup.
    # Use exec to replace the shell with the app.
    launcher_geometry
    hyprctl dispatch \
      "hl.dsp.exec_cmd([[kitty --class HyprLauncherRoot --title 'Launcher (root)' -- sudo -E bash -c 'exec $(esc_sq "$payload")']], { float = true, size = \"$GW $GH\", move = \"$GX $GY\" })" \
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
