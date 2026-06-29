#!/usr/bin/env bash
# Runs inside the kitty popup spawned by Launcher.sh. Builds caches,
# runs fzf with the router as the live data source, and dispatches the
# selected row through LauncherAct.sh.
#
# Enter        → run the selected entry normally
# Ctrl-X       → run it as administrator (polkit GUI prompt)
# Tab          → replace the query with the highlighted row
# Esc          → cancel
#
# Press F1 to open the glow-rendered help popup (LauncherHelp.sh).

set -u
SCRIPTS="$HOME/.config/hypr/scripts"

"$SCRIPTS/LauncherBuildCache.sh"

# --expect=ctrl-x makes fzf print the pressed key on the first output
# line (empty if plain Enter), then the selected row on the second.
# We wanted Ctrl-Enter but terminals can't distinguish it from Enter,
# so Ctrl-X stands in for "run as administrator".
sel=$(
  "$SCRIPTS/LauncherRouter.sh" "" |
    fzf \
      --delimiter=$'\t' \
      --with-nth=1 \
      --disabled \
      --prompt='> ' \
      --pointer='▶' \
      --marker='*' \
      --info=inline \
      --no-mouse \
      --reverse \
      --tiebreak=index \
      --expect=ctrl-x \
      --bind "change:reload:'$SCRIPTS/LauncherRouter.sh' {q}" \
      --bind 'esc:abort' \
      --bind 'tab:replace-query' \
      --bind "f1:execute-silent('$SCRIPTS/LauncherHelp.sh')" \
      --header=$'Just type to find apps. Start the query with a prefix to switch modes:\n   /  directories       >  shell commands       !  power options       F1  full help'
)

[[ -z "$sel" ]] && exit 0

key=$(printf '%s\n' "$sel" | sed -n 1p)
row=$(printf '%s\n' "$sel" | sed -n 2p)

[[ -z "$row" ]] && exit 0

# Split the selected TSV row into <display>\t<type>\t<payload>.
# (App rows embed extra search terms inside column 1 via ANSI conceal
# codes; LauncherBuildCache.sh handles that, this script doesn't care.)
IFS=$'\t' read -r _ type payload <<<"$row"

# Ctrl-Enter → run-as-root variant. LauncherAct.sh recognises the prefix.
if [[ "$key" == "ctrl-x" ]]; then  # "run as admin"
  type="root-$type"
fi

"$SCRIPTS/LauncherAct.sh" "$type" "$payload"
