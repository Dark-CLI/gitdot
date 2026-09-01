#!/usr/bin/env bash
# Fuzzy-search Hyprland keybinds in a floating kitty popup (fzf-driven).
# Parses ~/.config/hypr/lua/binds/*.lua and extracts each `hl.bind(...) --: description`
# line. Bindings without a `--:` comment are silently skipped so internal/repeated
# binds stay out of the list.

# If a search popup is already open, focus it instead of spawning a second one.
EXISTING=$(hyprctl clients -j 2>/dev/null | jq -r '.[] | select(.class == "HyprKeyBindsSearch") | .address' | head -1)
if [ -n "$EXISTING" ]; then
  hyprctl dispatch "hl.dsp.focus({ window = \"address:$EXISTING\" })" >/dev/null 2>&1
  exit 0
fi

BIND_DIR="$HOME/.config/hypr/lua/binds"
TMP_LIST="/tmp/hypr-keybinds.list"

# Build the (combo, description) list. Pad combo to fixed width so columns
# align in the fzf list.
awk '
  /^[[:space:]]*hl\.bind\(/ && /--:/ {
    match($0, /hl\.bind\("([^"]+)"/, m1); combo = m1[1]
    match($0, /--:[[:space:]]*(.*)$/, m2); desc = m2[1]
    sub(/[[:space:]]+$/, "", desc)
    if (combo != "" && desc != "") {
      printf "%-32s  %s\n", combo, desc
    }
  }
' "$BIND_DIR"/*.lua | sort -u > "$TMP_LIST"

# Focused monitor size for 54% x 67% popup.
read -r MON_W MON_H < <(hyprctl monitors -j 2>/dev/null | \
  jq -r '.[] | select(.focused == true) | "\(.width) \(.height)"')
[ -z "$MON_W" ] && MON_W=2560
[ -z "$MON_H" ] && MON_H=1440
W=$((MON_W * 54 / 100))
H=$((MON_H * 67 / 100))

# Launch fzf inside a floating kitty popup, then center it.
hyprctl dispatch \
  "hl.dsp.exec_cmd(\"kitty --class HyprKeyBindsSearch --title 'Search Keybinds' -- bash -c 'fzf --prompt=\\\"  \\\" --header=\\\"Type to filter • Esc to close\\\" --reverse --info=inline --border=rounded < $TMP_LIST > /dev/null; true'\", { float = true, size = \"$W $H\" })" \
  >/dev/null 2>&1

sleep 0.1
hyprctl dispatch "hl.dsp.focus({ class = \"HyprKeyBindsSearch\" })" >/dev/null 2>&1
hyprctl dispatch "hl.dsp.window.center({ respect_reserved = true })" >/dev/null 2>&1
