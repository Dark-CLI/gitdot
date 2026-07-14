#!/usr/bin/env bash
# Window switcher (SUPER+CTRL+S). Runs inside the HyprWinSwitch kitty
# popup spawned by WindowSwitcherLaunch.sh. Lists open windows via
# hyprctl clients, lets you fuzzy-search by "[wsN] class · title", and
# focuses the choice on Enter (Hyprland auto-jumps to that workspace).
#
# Enter        → focus the highlighted window
# Esc          → cancel

set -u

# Two-column TSV: <address> <display>. --with-nth=2 hides the address
# and restricts search to the visible column. Filter out this switcher
# itself so we don't offer it as a target.
list_rows() {
  hyprctl clients -j 2>/dev/null | jq -r '
    .[]
    | select(.class != "HyprWinSwitch")
    | [.address, "[ws\(.workspace.id)] \(.class) · \(.title)"]
    | @tsv
  '
}

sel=$(
  list_rows |
    fzf \
      --delimiter=$'\t' \
      --with-nth=2 \
      --prompt='> ' \
      --pointer='▶' \
      --marker='*' \
      --info=inline \
      --no-mouse \
      --reverse \
      --tiebreak=index \
      --bind 'esc:abort' \
      --header=$'Enter  focus window'
)

[[ -z "$sel" ]] && exit 0

# Column 1 is the address (0x…). Focus jumps workspaces automatically.
addr=$(printf '%s' "$sel" | cut -f1)
[[ -z "$addr" ]] && exit 0

hyprctl dispatch "hl.dsp.focus({ window = \"address:$addr\" })" >/dev/null 2>&1
