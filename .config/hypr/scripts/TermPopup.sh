#!/usr/bin/env bash
# Shared launcher for terminal-based menus (app launcher, clipboard,
# file browser, help popup, …). Handles the three things every one of
# them needs:
#   1. Single-instance: if a window with the given class already exists,
#      focus it and exit.
#   2. Centered geometry: PCT_W × PCT_H of the focused monitor.
#   3. Dispatch a floating kitty running the given command.
#
# Usage:
#   TermPopup.sh --class <str> --title <str> [--size PWxPH] -- <cmd>
#
# <cmd> is a single string handed to `kitty -- sh -c '<cmd>'`, so complex
# commands with pipes / redirects work as-is; a single-script path is
# also fine. Only the outer single quotes need escaping (heredoc-style).
#
# Example:
#   TermPopup.sh --class HyprLauncher --title Launcher -- \
#       "$HOME/.config/hypr/scripts/LauncherInner.sh"

set -u

CLASS=""
TITLE=""
PCT_W=52
PCT_H=60

while [ $# -gt 0 ]; do
  case "$1" in
    --class) CLASS="$2"; shift 2 ;;
    --title) TITLE="$2"; shift 2 ;;
    --size)
      # Format: WxH (percents of focused monitor).
      PCT_W="${2%x*}"
      PCT_H="${2#*x}"
      shift 2
      ;;
    --) shift; break ;;
    *) echo "TermPopup.sh: unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ -z "$CLASS" ] || [ -z "$TITLE" ] || [ $# -eq 0 ]; then
  echo "usage: TermPopup.sh --class <str> --title <str> [--size PWxPH] -- <cmd>" >&2
  exit 2
fi
CMD="$*"

# Single-quote escape for embedding into `sh -c '...'`.
sh_esc() { printf %s "$1" | sed "s/'/'\\\\''/g"; }
CMD_SH=$(sh_esc "$CMD")

# Single-instance: focus the existing popup instead of spawning a second.
EXISTING=$(hyprctl clients -j 2>/dev/null |
  jq -r --arg cls "$CLASS" '.[] | select(.class == $cls) | .address' | head -1)
if [ -n "$EXISTING" ]; then
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$EXISTING\" })" >/dev/null 2>&1
  exit 0
fi

# The dropdown terminal lives on `special:scratchpad`. Special
# workspaces render as an overlay ABOVE regular workspace windows, so
# if the scratchpad is currently visible it would sit on top of this
# popup. Hide it first — user can re-summon the dropdown after closing
# the menu.
active_special=$(hyprctl monitors -j 2>/dev/null |
  jq -r '.[] | select(.focused == true) | .specialWorkspace.name // ""')
if [ "$active_special" = "special:scratchpad" ]; then
  hyprctl dispatch 'hl.dsp.workspace.toggle_special({ name = "scratchpad" })' >/dev/null 2>&1
fi

# Calculate window size based on focused monitor
read -r MW MH < <(hyprctl monitors -j 2>/dev/null |
  jq -r '.[] | select(.focused == true) | "\(.width) \(.height)"')
[ -z "$MW" ] && MW=2560
[ -z "$MH" ] && MH=1440

W=$((MW * PCT_W / 100))
H=$((MH * PCT_H / 100))

# Spawn the window
hyprctl dispatch \
  "hl.dsp.exec_cmd([[kitty --class $CLASS --title '$TITLE' -- sh -c '$CMD_SH']], { float = true, size = \"$W $H\" })" \
  >/dev/null 2>&1

# Wait for window to spawn and ensure it's focused, then center it
sleep 0.1
hyprctl dispatch "hl.dsp.focus({ class = \"$CLASS\" })" >/dev/null 2>&1
hyprctl dispatch "hl.dsp.window.center({ respect_reserved = true })" >/dev/null 2>&1
