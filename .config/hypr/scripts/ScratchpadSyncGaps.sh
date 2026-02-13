#!/usr/bin/env bash
# Sync pyprland dropdown terminal position/size to match current window gaps.
# Run automatically when gaps change (GapControl.sh) or on Hyprland startup.
# Ensures the scratchpad has the same spacing from edges as tiled windows.

PYPRLAND_TOML="$HOME/.config/hypr/pyprland.toml"
# Size as percentage of USABLE area (inside gaps). Edit to change dropdown size.
SIZE_FACTOR_W=55
SIZE_FACTOR_H=70

gaps_out=$(hyprctl getoption general:gaps_out -j | jq -r 'if .int then .int else (.custom | split(" ") | .[0] | tonumber) end')
[[ -z "$gaps_out" || "$gaps_out" == "null" ]] && gaps_out=0

# Get focused monitor dimensions
mon=$(hyprctl monitors -j | jq -r '.[] | select(.focused == true) | "\(.width) \(.height)"')
read -r width height <<< "$mon"
[[ -z "$width" || -z "$height" ]] && exit 1

# Position: gaps_out pixels from top-left → percentage of monitor (integers only - pyprland rejects decimals)
pos_x_pct=$(awk "BEGIN { printf \"%.0f\", 100 * $gaps_out / $width }")
pos_y_pct=$(awk "BEGIN { printf \"%.0f\", 100 * $gaps_out / $height }")

# Size: SIZE_FACTOR% of usable area (minus gaps on both sides)
usable_w=$((width - 2 * gaps_out))
usable_h=$((height - 2 * gaps_out))
[[ $usable_w -lt 100 ]] && usable_w=100
[[ $usable_h -lt 100 ]] && usable_h=100

size_w_pct=$(awk "BEGIN { printf \"%.0f\", 100 * ($usable_w * $SIZE_FACTOR_W / 100) / $width }")
size_h_pct=$(awk "BEGIN { printf \"%.0f\", 100 * ($usable_h * $SIZE_FACTOR_H / 100) / $height }")

# Update pyprland.toml (size/position only appear in [scratchpads.term])
sed -i "s|^size = .*|size = \"${size_w_pct}% ${size_h_pct}%\"|" "$PYPRLAND_TOML"
sed -i "s|^position = .*|position = \"${pos_x_pct}% ${pos_y_pct}%\"|" "$PYPRLAND_TOML"

# Restart pyprland to apply changes (reload doesn't re-apply scratchpad window rules)
pkill pypr 2>/dev/null
sleep 0.2
pypr &
