#!/usr/bin/env bash
# Called from ClipMenu.sh via fzf's Ctrl-E bind. Takes one arg: the
# selected cliphist row ("<id>\t<preview>"). Decodes it to a tempfile,
# opens nvim on it, then wl-copies the edited content back — the copy
# is dispatched through Hyprland (via hl.dsp.exec_cmd) so wl-copy's
# background daemon doesn't inherit the fzf popup's pty and keep it
# alive after we abort back out of fzf.

set -u

row="${1:-}"
[[ -z "$row" ]] && exit 0

T=$(mktemp --suffix=.clip)
printf '%s' "$row" | cliphist decode >"$T"
${EDITOR:-nvim} "$T"

hyprctl dispatch \
  "hl.dsp.exec_cmd([[sh -c 'wl-copy <$T; rm -f $T']])" \
  >/dev/null 2>&1
