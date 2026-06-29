#!/usr/bin/env bash
# Called by fzf on every keystroke change. Reads the current query,
# picks a data source by prefix, dumps a TSV list to stdout.
#
# Output is always 4 columns (display, type, payload, source-path).
# The 4th column is the .desktop file path for app rows (used by the
# Ctrl-E "open in nvim" bind in LauncherInner.sh) and an empty string
# for dirs / cmds / power.
#
# The outer fzf in LauncherInner.sh runs with --disabled and does no
# filtering of its own, so every branch below must filter to the query
# itself. We use `fzf --filter` (non-interactive) as the matcher.
#
# Prefixes:
#   (none)  → installed applications
#   /...    → directories under $HOME (Enter opens kitty+tmux at the path)
#   >...    → shell commands (first row = run query literally;
#             rest = matching ~/.zsh_history entries)
#   !...    → power actions (lock / logout / suspend / reboot / shutdown)
#
# Help is a separate glow popup triggered by F1 inside the launcher
# (see scripts/LauncherHelp.sh); no `?` prefix here.

set -u

CACHE="$HOME/.cache/hypr-launcher"
q="${1:-}"

case "$q" in
  /*)
    dir_q="${q#/}"
    # dirs.tsv already has the empty source-path column; pass it through.
    fzf --filter="$dir_q" --delimiter=$'\t' --nth=1 \
        <"$CACHE/dirs.tsv" 2>/dev/null |
      cut -f1,2,3,5
    ;;

  '>'*)
    cmd_q="${q#>}"
    cmd_q="${cmd_q# }"
    if [[ -n "$cmd_q" ]]; then
      printf '>  run: %s\t%s\t%s\t\n' "$cmd_q" "cmd" "$cmd_q"
    fi
    sed -nE 's/^: [0-9]+:[0-9]+;//p' "$HOME/.zsh_history" 2>/dev/null |
      tac |
      awk '!seen[$0]++ { if (length($0) > 0) printf ">  %s\tcmd\t%s\t\n", $0, $0 }' |
      fzf --filter="$cmd_q" --delimiter=$'\t' --nth=1 2>/dev/null
    ;;

  '!'*)
    pwr_q="${q#!}"
    pwr_q="${pwr_q# }"
    fzf --filter="$pwr_q" --delimiter=$'\t' --nth=1 <<'EOF' 2>/dev/null | sed 's/$/\t/'
!  Lock	power	lock
!  Logout	power	logout
!  Suspend	power	suspend
!  Reboot	power	reboot
!  Shutdown	power	shutdown
EOF
    ;;

  *)
    # apps.tsv: 5 cols (display, type, payload, extras, source-path).
    # Filter against name (column 1) and metadata (column 4) separately
    # then dedupe so name matches outrank metadata-only matches. Strip
    # column 4 (extras); keep column 5 (source path) as the new col 4.
    {
      fzf --filter="$q" --delimiter=$'\t' --nth=1 <"$CACHE/apps.tsv" 2>/dev/null
      fzf --filter="$q" --delimiter=$'\t' --nth=4 <"$CACHE/apps.tsv" 2>/dev/null
    } |
      awk '!seen[$0]++ && length($0) > 0' |
      cut -f1,2,3,5
    ;;
esac
