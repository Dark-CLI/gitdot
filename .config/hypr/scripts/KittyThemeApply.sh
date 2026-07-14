#!/usr/bin/env bash
# Apply a kitty theme by rewriting the `include ./kitty-themes/<X>.conf`
# line in kitty.conf and SIGUSR1-ing every running kitty so it reloads.
# Called from Kitty_themes.sh via fzf's focus/enter binds.
#
# Usage: KittyThemeApply.sh <theme-name-without-.conf>

set -u

theme="${1:-}"
[[ -z "$theme" ]] && exit 0

kitty_themes_DiR="$HOME/.config/kitty/kitty-themes"
kitty_config="$HOME/.config/kitty/kitty.conf"
theme_file="$kitty_themes_DiR/$theme.conf"

[[ -f "$theme_file" ]] || exit 1

tmp=$(mktemp)
cp "$kitty_config" "$tmp"

if grep -qE '^[#[:space:]]*include\s+\./kitty-themes/.*\.conf' "$tmp"; then
  sed -i -E "s|^([#[:space:]]*include\s+\./kitty-themes/).*\.conf|include ./kitty-themes/$theme.conf|g" "$tmp"
else
  # Ensure a trailing newline before appending.
  [[ -s "$tmp" && "$(tail -c1 "$tmp")" != $'\n' ]] && echo >>"$tmp"
  echo "include ./kitty-themes/$theme.conf" >>"$tmp"
fi

mv "$tmp" "$kitty_config"

for pid in $(pidof kitty); do
  kill -SIGUSR1 "$pid" 2>/dev/null || true
done
