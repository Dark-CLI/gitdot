#!/usr/bin/env bash
# Search Hyprland keybinds via rofi
# Parses ~/.config/hypr/lua/binds/*.lua and extracts each hl.bind() call
# along with the trailing "--:" comment as the description.
#
# Format expected in lua files:
#   hl.bind("SUPER + D", hl.dsp.exec_cmd("...")) --: app launcher

# Kill any running rofi
if pidof rofi >/dev/null; then
  pkill rofi
fi

ROFI_THEME="$HOME/.config/rofi/config-keybinds.rasi"
BIND_DIR="$HOME/.config/hypr/lua/binds"
MSG='🔍 Search Hyprland keybinds (live from your Lua config)'

# Extract key combo (the first string argument to hl.bind) and the trailing
# --: comment from every hl.bind line across the bind files.
# Lines without a --: comment are skipped — only documented binds show up.
list=$(grep -hnE '^\s*hl\.bind\(' "$BIND_DIR"/*.lua | \
  awk -F: '
    {
      file=$1
      # rejoin everything after the file:line: prefix
      line=""
      for (i=2; i<=NF; i++) line = line (i>2 ? ":" : "") $i
      # capture first quoted string => key combo
      if (match(line, /hl\.bind\("([^"]+)"/, m1)) {
        combo = m1[1]
      } else { next }
      # capture description after --:
      if (match(line, /--:[[:space:]]*(.*)$/, m2)) {
        desc = m2[1]
        # strip trailing whitespace
        sub(/[[:space:]]+$/, "", desc)
        printf "%-32s  %s\n", combo, desc
      }
    }
  ' | sort -u)

# Show in rofi
echo "$list" | rofi -dmenu -i -p "Keybinds" -mesg "$MSG" -theme "$ROFI_THEME" >/dev/null 2>&1
