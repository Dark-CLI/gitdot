#!/usr/bin/env bash
# Clipboard picker (SUPER+V). Runs inside the kitty popup spawned by
# ClipMenuLaunch.sh. Reads cliphist history, lets you fuzzy-search it,
# copies the chosen entry back to the clipboard.
#
# Enter        → decode + wl-copy the highlighted entry (via hyprctl
#                dispatch so this kitty exits cleanly)
# Ctrl-E       → open the highlighted entry in nvim, wl-copy the edit
# Ctrl-X       → delete just the highlighted entry, list refreshes in place
# Ctrl-D       → wipe the entire cliphist history, list refreshes in place
# Esc          → cancel

set -u

# cliphist list emits "<id>\t<preview>". Search only against the preview
# column and hide the id from the display; the id survives in the row
# so cliphist decode / delete can round-trip it.
#
# Delete + wipe use execute-silent + reload so the fzf list refreshes
# in place without restarting the whole picker — no window flash on
# rapid Ctrl-X presses.
sel=$(
  cliphist list |
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
      --bind "ctrl-e:execute($HOME/.config/hypr/scripts/ClipEdit.sh {})+abort" \
      --bind 'ctrl-x:execute-silent(cliphist delete <<< {})+reload(cliphist list)' \
      --bind 'ctrl-d:execute-silent(cliphist wipe)+reload(cliphist list)' \
      --header=$'Enter  select  |  Ctrl-E  edit in nvim  |  Ctrl-X  delete entry  |  Ctrl-D  wipe all'
)

[[ -z "$sel" ]] && exit 0

# Dispatch the copy through Hyprland so it runs OUTSIDE this kitty
# popup (wl-copy forks a daemon that would otherwise hold the popup's
# pty and keep the window alive — same trick LauncherAct.sh uses).
# The selected row can contain arbitrary characters (quotes, newlines,
# etc.), so drop it into a tempfile instead of embedding it in the
# dispatch payload. The dispatched shell decodes from the tempfile and
# cleans up.
TMP=$(mktemp)
printf '%s' "$sel" >"$TMP"
hyprctl dispatch \
  "hl.dsp.exec_cmd([[sh -c 'cliphist decode <$TMP | wl-copy; rm -f $TMP']])" \
  >/dev/null 2>&1
