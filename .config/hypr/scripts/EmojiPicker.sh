#!/usr/bin/env bash
# Emoji picker (SUPER+ALT+E). Runs inside the HyprEmoji kitty popup
# spawned by EmojiPickerLaunch.sh. Fuzzy-searches ~1800 emoji by name /
# tags, copies the chosen emoji to the clipboard on Enter.
#
# Enter        → wl-copy the emoji (paste with Ctrl+V wherever)
# Esc          → cancel
#
# The emoji dataset is a big HEREDOC at the bottom of RofiEmoji.sh
# (each line: "<emoji> <descriptions...>"). Reuse it verbatim so we
# don't duplicate ~1800 lines.

set -u

SCRIPTS="$HOME/.config/hypr/scripts"

list_emoji() { sed '1,/^# # DATA # #$/d' "$SCRIPTS/RofiEmoji.sh"; }

sel=$(
  list_emoji |
    fzf \
      --prompt='> ' \
      --pointer='▶' \
      --marker='*' \
      --info=inline \
      --no-mouse \
      --reverse \
      --tiebreak=index \
      --bind 'esc:abort' \
      --header=$'Enter  copy emoji (paste with Ctrl+V)'
)

[[ -z "$sel" ]] && exit 0

# First whitespace-delimited field is the emoji glyph itself. Write to
# a tempfile and dispatch wl-copy through Hyprland so wl-copy's
# background daemon doesn't inherit this kitty's pty and hold it open.
emoji=$(awk '{ print $1; exit }' <<<"$sel")
[[ -z "$emoji" ]] && exit 0

TMP=$(mktemp)
printf '%s' "$emoji" >"$TMP"
hyprctl dispatch \
  "hl.dsp.exec_cmd([[sh -c 'wl-copy <$TMP; rm -f $TMP']])" \
  >/dev/null 2>&1
