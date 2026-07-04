#!/usr/bin/env bash
# Runs inside the kitty popup spawned by Launcher.sh. Builds caches,
# runs fzf with the router as the live data source, and dispatches the
# selected row through LauncherAct.sh.
#
# Enter        → run the selected entry normally
# Ctrl-X       → run it as administrator (polkit GUI prompt)
# Ctrl-E       → open the row's source .desktop in nvim (apps only)
# Tab          → replace the query with the highlighted row
# Esc          → cancel
# F1           → open the glow-rendered help popup (LauncherHelp.sh)
# F5           → force-rebuild the apps + dirs caches and reload the list

set -u
SCRIPTS="$HOME/.config/hypr/scripts"
CACHE="$HOME/.cache/hypr-launcher"

# Fast-start policy: only block on the cache builder when there is
# literally nothing to show (first ever launch). Otherwise the launcher
# opens instantly against the existing cache and the rebuild runs in
# the background — the results land in place via atomic mv, so the
# *next* launch picks them up. F5 still forces a foreground rebuild.
if [[ -s "$CACHE/apps.tsv" ]]; then
  setsid -f "$SCRIPTS/LauncherBuildCache.sh" >/dev/null 2>&1 </dev/null || true
else
  "$SCRIPTS/LauncherBuildCache.sh"
fi

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
      --bind "f5:execute-silent(FORCE=1 '$SCRIPTS/LauncherBuildCache.sh')+reload('$SCRIPTS/LauncherRouter.sh' {q})" \
      --bind "ctrl-e:execute('$SCRIPTS/LauncherEditDesktop.sh' {4})" \
      --header=$'Just type to find apps. Start the query with a prefix to switch modes:\n   /  directories       >  shell commands       !  power options       F1  full help'
)

[[ -z "$sel" ]] && exit 0

key=$(printf '%s\n' "$sel" | sed -n 1p)
row=$(printf '%s\n' "$sel" | sed -n 2p)

[[ -z "$row" ]] && exit 0

# Split the selected TSV row. Column 4 is the source .desktop path for
# apps (empty for dirs/cmds/power); we ignore it here because Ctrl-E
# already handled it inside fzf.
IFS=$'\t' read -r _ type payload _src <<<"$row"

# Ctrl-X → run-as-root variant. LauncherAct.sh recognises the prefix.
if [[ "$key" == "ctrl-x" ]]; then
  type="root-$type"
fi

"$SCRIPTS/LauncherAct.sh" "$type" "$payload"
