#!/usr/bin/env bash
# Called by fzf on every keystroke change. Reads the current query,
# picks a data source by prefix, dumps a TSV list to stdout. Caches are
# built by LauncherBuildCache.sh.
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
    cat "$CACHE/dirs.tsv" 2>/dev/null
    ;;

  '>'*)
    cmd_q="${q#>}"
    cmd_q="${cmd_q# }"
    if [[ -n "$cmd_q" ]]; then
      printf '>  run: %s\t%s\t%s\n' "$cmd_q" "cmd" "$cmd_q"
    fi
    # Parse zsh extended history: ': <ts>:<elapsed>;<cmd>'. Strip prefix,
    # dedupe (most-recent-first), drop blanks.
    sed -nE 's/^: [0-9]+:[0-9]+;//p' "$HOME/.zsh_history" 2>/dev/null |
      tac |
      awk '!seen[$0]++ { if (length($0) > 0) printf ">  %s\tcmd\t%s\n", $0, $0 }'
    ;;

  '!'*)
    # Power actions. The leading "!" makes fzf's prefix filter pick
    # them up when the user types `!`.
    cat <<'EOF'
!  Lock	power	lock
!  Logout	power	logout
!  Suspend	power	suspend
!  Reboot	power	reboot
!  Shutdown	power	shutdown
EOF
    ;;

  *)
    # App mode: apps.tsv has a hidden 4th column (GenericName / Comment
    # / Keywords / StartupWMClass) used for fuzzy matching. Run fzf in
    # filter mode here with --nth=1,4 to search visible name + extras,
    # then drop the extras column so the outer fzf only ever sees three.
    fzf --filter="$q" --delimiter=$'\t' --nth=1,4 \
        <"$CACHE/apps.tsv" 2>/dev/null |
      cut -f1,2,3
    ;;
esac
