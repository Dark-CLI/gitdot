#!/usr/bin/env bash
# Called by fzf on every keystroke change. Reads the current query,
# picks a data source by prefix, dumps a TSV list to stdout. Caches are
# built by LauncherBuildCache.sh.
#
# The outer fzf in LauncherInner.sh runs with --disabled and does no
# filtering of its own, so every branch below must filter to the query
# itself. We use `fzf --filter` (non-interactive) as the matcher to
# keep ranking consistent across modes.
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
    # Strip the leading "/" from the query — the rows already start
    # with "/  …" so fuzzy-matching the rest of the path is the goal.
    dir_q="${q#/}"
    fzf --filter="$dir_q" --delimiter=$'\t' --nth=1 \
        <"$CACHE/dirs.tsv" 2>/dev/null
    ;;

  '>'*)
    cmd_q="${q#>}"
    cmd_q="${cmd_q# }"
    # Run-literal row (only if the user has actually typed something).
    if [[ -n "$cmd_q" ]]; then
      printf '>  run: %s\t%s\t%s\n' "$cmd_q" "cmd" "$cmd_q"
    fi
    # zsh extended history: ': <ts>:<elapsed>;<cmd>'. Strip prefix,
    # dedupe (most-recent-first), drop blanks, then filter to the query.
    sed -nE 's/^: [0-9]+:[0-9]+;//p' "$HOME/.zsh_history" 2>/dev/null |
      tac |
      awk '!seen[$0]++ { if (length($0) > 0) printf ">  %s\tcmd\t%s\n", $0, $0 }' |
      fzf --filter="$cmd_q" --delimiter=$'\t' --nth=1 2>/dev/null
    ;;

  '!'*)
    pwr_q="${q#!}"
    pwr_q="${pwr_q# }"
    fzf --filter="$pwr_q" --delimiter=$'\t' --nth=1 <<'EOF' 2>/dev/null
!  Lock	power	lock
!  Logout	power	logout
!  Suspend	power	suspend
!  Reboot	power	reboot
!  Shutdown	power	shutdown
EOF
    ;;

  *)
    # App mode: apps.tsv has a hidden 4th column (GenericName / Comment
    # / Keywords / StartupWMClass) used for fuzzy matching.
    #
    # Run fzf twice — first against the visible name (column 1), then
    # against the metadata (column 4) — and concat the results. awk
    # '!seen[$0]++' dedupes while preserving order, so name matches
    # appear first and metadata-only matches come after. The outer
    # column-4 strip keeps the data the inner fzf receives at 3 cols.
    {
      fzf --filter="$q" --delimiter=$'\t' --nth=1 <"$CACHE/apps.tsv" 2>/dev/null
      fzf --filter="$q" --delimiter=$'\t' --nth=4 <"$CACHE/apps.tsv" 2>/dev/null
    } |
      awk '!seen[$0]++ && length($0) > 0' |
      cut -f1,2,3
    ;;
esac
