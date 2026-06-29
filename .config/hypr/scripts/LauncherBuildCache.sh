#!/usr/bin/env bash
# Build the static caches read by LauncherRouter.sh:
#   ~/.cache/hypr-launcher/apps.tsv  — one row per installed .desktop entry
#   ~/.cache/hypr-launcher/dirs.tsv  — every dir under $HOME (modulo fd's
#                                      default ignores: .git, node_modules,
#                                      .cache, etc.)
#
# Each row is tab-separated:
#   <display>   <action-type>   <action-payload>
# fzf shows only column 1 via --with-nth=1; column 2/3 carry the dispatch.
#
# Refresh model:
#   apps.tsv  — rebuilt only if any .desktop file is newer than the cache
#   dirs.tsv  — refreshed each launch (fd is fast, <100ms warm)
#
# To customise the glyph used per app, edit `glyph_for_app` below.

set -eu

CACHE="$HOME/.cache/hypr-launcher"
mkdir -p "$CACHE"

APP_DIRS=(
  "/usr/share/applications"
  "/usr/local/share/applications"
  "$HOME/.local/share/applications"
  "/var/lib/flatpak/exports/share/applications"
  "$HOME/.local/share/flatpak/exports/share/applications"
)

# Build apps.tsv only if any source .desktop is newer than the cache.
build_apps_if_stale() {
  local apps="$CACHE/apps.tsv"
  if [[ -f "$apps" ]]; then
    if ! find "${APP_DIRS[@]}" -maxdepth 1 -name '*.desktop' -newer "$apps" -print -quit 2>/dev/null | grep -q .; then
      return 0
    fi
  fi

  # Parse all .desktop files. Skip NoDisplay/Hidden and non-Application types.
  : >"$apps.tmp"
  for d in "${APP_DIRS[@]}"; do
    [[ -d "$d" ]] || continue
    for f in "$d"/*.desktop; do
      [[ -f "$f" ]] || continue

      # Take the first [Desktop Entry] section only.
      local section name exec type nodisplay hidden
      section=$(awk '
        /^\[Desktop Entry\]/        { in_main=1; next }
        in_main && /^\[/            { exit }
        in_main                     { print }
      ' "$f")

      [[ -z "$section" ]] && continue

      type=$(awk -F= '/^Type=/        { print $2; exit }' <<<"$section")
      [[ "$type" != "Application" ]] && continue

      nodisplay=$(awk -F= '/^NoDisplay=/ { print $2; exit }' <<<"$section")
      hidden=$(awk -F= '/^Hidden=/    { print $2; exit }' <<<"$section")
      [[ "$nodisplay" == "true" || "$hidden" == "true" ]] && continue

      name=$(awk -F= '/^Name=/       { print $2; exit }' <<<"$section")
      exec=$(awk -F= '/^Exec=/       { sub(/^Exec=/, ""); print; exit }' <<<"$section")
      # Strip Exec field codes (%f %u %F %U %i %c %k)
      exec=$(sed -E 's/%[fFuUickdDnNvm]//g; s/  +/ /g; s/ +$//' <<<"$exec")

      [[ -z "$name" || -z "$exec" ]] && continue

      # Terminal=true → app needs to be wrapped in a terminal (htop, vim, …).
      # Encoded as a separate action type so LauncherAct.sh knows to wrap.
      local term action
      term=$(awk -F= '/^Terminal=/   { print $2; exit }' <<<"$section")
      if [[ "$term" == "true" ]]; then
        action="term-app"
      else
        action="app"
      fi

      # Hidden 4th column used for fuzzy matching only. LauncherRouter.sh
      # filters apps.tsv internally with --nth=1,4 and then strips this
      # column before emitting to the outer fzf — so the extras are
      # searchable but never displayed.
      local gen_name comment keywords wm_class extras
      gen_name=$(awk -F= '/^GenericName=/        { sub(/^GenericName=/, ""); print; exit }' <<<"$section")
      comment=$(awk -F=  '/^Comment=/            { sub(/^Comment=/, ""); print; exit }' <<<"$section")
      keywords=$(awk -F= '/^Keywords=/           { sub(/^Keywords=/, ""); print; exit }' <<<"$section")
      wm_class=$(awk -F= '/^StartupWMClass=/     { sub(/^StartupWMClass=/, ""); print; exit }' <<<"$section")
      keywords="${keywords%;}"
      keywords="${keywords//;/ }"
      extras=$(printf '%s %s %s %s' "$gen_name" "$comment" "$keywords" "$wm_class" |
        tr '\t' ' ' | awk '{$1=$1; print}')

      # 5 columns: display, action, exec, hidden search extras, source .desktop path.
      # The 5th column is what `ctrl-e` in LauncherInner.sh opens in nvim.
      printf '%s\t%s\t%s\t%s\t%s\n' "$name" "$action" "$exec" "$extras" "$f" >>"$apps.tmp"
    done
  done

  # Stable sort by name (column 1, after glyph).
  sort -t$'\t' -k1,1 -u "$apps.tmp" >"$apps"
  rm -f "$apps.tmp"
}

build_dirs() {
  local dirs="$CACHE/dirs.tsv"
  # Cache for 1 hour. Delete dirs.tsv to force a refresh.
  if [[ -f "$dirs" ]]; then
    local age=$(( $(date +%s) - $(stat -c %Y "$dirs") ))
    (( age < 3600 )) && return 0
  fi

  # Hard-exclude the well-known noise dirs (build caches, IDE state,
  # game stores, package managers). --max-depth caps unbounded nesting
  # (project trees, node_modules survivors).
  fd -t d --hidden --max-depth 6 \
     --exclude .git --exclude node_modules --exclude target \
     --exclude .cache --exclude .npm --exclude .cargo --exclude .rustup \
     --exclude .gradle --exclude .steam --exclude .pub-cache \
     --exclude .var --exclude .vscode --exclude .cursor --exclude .oh-my-zsh \
     --exclude .mozilla --exclude .ipfs --exclude .android \
     --exclude .local --exclude android-sdk --exclude Android --exclude flutter \
     --exclude .local/share/Trash \
     . "$HOME" 2>/dev/null |
    awk -v home="$HOME/" '
      { rel = $0; sub(home, "", rel); printf "/  %s\t%s\t%s\t\t\n", rel, "dir", $0 }
    ' >"$dirs"
}

build_apps_if_stale
build_dirs
