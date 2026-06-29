#!/usr/bin/env bash
# Open the highlighted launcher row's .desktop source in nvim, inside
# the launcher's own kitty (via fzf's `execute` binding, which suspends
# fzf for the duration). Returns to the launcher when nvim exits.
#
# Args: $1 = .desktop file path (the 4th column emitted by
# LauncherRouter.sh). For dir / cmd / power rows this is empty — we
# show a one-line message and wait for any key so the user knows why
# nothing opened.

path="${1:-}"

if [[ -z "$path" ]]; then
  printf '\nNo .desktop file for this row (Ctrl-E only works on apps).\n'
  printf 'Press any key to return…'
  read -rsn1
  exit 0
fi

exec nvim "$path"
