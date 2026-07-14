#!/usr/bin/env bash
# Pick a kitty terminal theme with live preview. Runs inside whatever
# kitty popup its caller (Kool_Quick_Settings hub) already opened.
#
# Enter        → keep the highlighted theme
# Esc          → revert to the theme active when this script started

set -u

kitty_themes_DiR="$HOME/.config/kitty/kitty-themes"
kitty_config="$HOME/.config/kitty/kitty.conf"
iDIR="$HOME/.config/swaync/images"
APPLY="$HOME/.config/hypr/scripts/KittyThemeApply.sh"

notify_user() { notify-send -u low -i "$1" "$2" "$3"; }

if [[ ! -d "$kitty_themes_DiR" ]]; then
  notify_user "$iDIR/error.png" "E-R-R-O-R" "Kitty Themes directory not found: $kitty_themes_DiR"
  exit 1
fi

# Snapshot kitty.conf so Esc can restore it byte-for-byte.
BACKUP=$(mktemp --suffix=.kitty.conf.bak)
cp "$kitty_config" "$BACKUP"

# Build sorted theme name list (basename minus .conf).
mapfile -t themes < <(
  find "$kitty_themes_DiR" -maxdepth 1 -name '*.conf' -type f -printf '%f\n' |
    sed 's/\.conf$//' | sort
)
if (( ${#themes[@]} == 0 )); then
  notify_user "$iDIR/error.png" "No Kitty Themes" "No .conf files found in $kitty_themes_DiR."
  exit 1
fi

# Detect currently-active theme so we can start the cursor on it.
current=$(awk -F'include ./kitty-themes/|\\.conf' \
  '/^[[:space:]]*include \.\/kitty-themes\/.*\.conf/{print $2; exit}' "$kitty_config")

chosen=$(
  printf '%s\n' "${themes[@]}" |
    fzf \
      --prompt='> ' \
      --pointer='▶' \
      --marker='*' \
      --info=inline \
      --no-mouse \
      --reverse \
      --tiebreak=index \
      --query="$current" \
      --bind "focus:execute-silent($APPLY {})" \
      --bind 'esc:abort' \
      --header='Enter  keep    Esc  revert    (live preview on scroll)'
)

if [[ -z "$chosen" ]]; then
  # Cancelled — restore original kitty.conf and SIGUSR1 any running kitties.
  cp "$BACKUP" "$kitty_config"
  for pid in $(pidof kitty); do kill -SIGUSR1 "$pid" 2>/dev/null || true; done
  notify_user "$iDIR/note.png" "Kitty Theme" "Selection cancelled. Reverted."
else
  # `focus` already applied on the way in, but re-apply once for safety
  # in case Enter fired without a preceding focus event.
  "$APPLY" "$chosen"
  notify_user "$iDIR/ja.png" "Kitty Theme Applied" "$chosen"
fi

rm -f "$BACKUP"
