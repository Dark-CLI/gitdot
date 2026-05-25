#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */
# This script for selecting wallpapers (SUPER W)

# WALLPAPERS PATH
terminal=kitty
wallDIR="$HOME/Pictures/wallpapers"
SCRIPTSDIR="$HOME/.config/hypr/scripts"
wallpaper_current="$HOME/.config/hypr/wallpaper_effects/.wallpaper_current"

# Directory for swaync
iDIR="$HOME/.config/swaync/images"
iDIRi="$HOME/.config/swaync/icons"

# swww transition config
FPS=60
TYPE="any"
DURATION=2
BEZIER=".43,1.19,1,.4"
SWWW_PARAMS=("--transition-fps" "$FPS" "--transition-type" "$TYPE" "--transition-duration" "$DURATION" "--transition-bezier" "$BEZIER")

# Check if package bc exists
if ! command -v bc &>/dev/null; then
  notify-send -i "$iDIR/error.png" "bc missing" "Install package bc first"
  exit 1
fi

# Variables
rofi_theme="$HOME/.config/rofi/config-wallpaper.rasi"
focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

# Ensure focused_monitor is detected
if [[ -z "$focused_monitor" ]]; then
  notify-send -i "$iDIR/error.png" "E-R-R-O-R" "Could not detect focused monitor"
  exit 1
fi

# Monitor details
scale_factor=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .scale')
monitor_height=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" '.[] | select(.name == $mon) | .height')

icon_size=$(echo "scale=1; ($monitor_height * 3) / ($scale_factor * 150)" | bc)
adjusted_icon_size=$(echo "$icon_size" | awk '{if ($1 < 15) $1 = 20; if ($1 > 25) $1 = 25; print $1}')
rofi_override="element-icon{size:${adjusted_icon_size}%;}"

# Kill existing wallpaper daemons for video
kill_wallpaper_for_video() {
  swww kill 2>/dev/null
  pkill mpvpaper 2>/dev/null
  pkill swaybg 2>/dev/null
  pkill hyprpaper 2>/dev/null
}

# Kill existing wallpaper daemons for image
kill_wallpaper_for_image() {
  pkill mpvpaper 2>/dev/null
  pkill swaybg 2>/dev/null
  pkill hyprpaper 2>/dev/null
}

# Retrieve wallpapers (both images & videos)
mapfile -d '' PICS < <(find -L "${wallDIR}" -type f \( \
  -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o \
  -iname "*.bmp" -o -iname "*.tiff" -o -iname "*.webp" -o \
  -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.webm" \) -print0)

RANDOM_PIC="${PICS[$((RANDOM % ${#PICS[@]}))]}"
RANDOM_PIC_NAME=". random"

# Cache file for last selected wallpaper
wallpaper_cache_file="$HOME/.cache/hypr/wallpaper_last_selected"
mkdir -p "$HOME/.cache/hypr"

# Sorting Wallpapers with state management
menu() {
  IFS=$'\n' sorted_options=($(sort <<<"${PICS[*]}"))

  # Load last selected wallpaper
  local last_selected=""
  if [ -f "$wallpaper_cache_file" ]; then
    last_selected=$(cat "$wallpaper_cache_file")
  fi

  # Find row number of last selected (0-indexed, accounting for random item at position 0)
  local selection_row=0
  if [ -n "$last_selected" ]; then
    local row=1  # Start at 1 because ". random" is at row 0
    for pic_path in "${sorted_options[@]}"; do
      pic_name=$(basename "$pic_path")
      if [[ "$pic_name" == "$last_selected" ]]; then
        selection_row=$row
        break
      fi
      ((row++))
    done
  fi

  # Store row number for use in rofi command
  echo "$selection_row" > "$HOME/.cache/hypr/wallpaper_selected_row"

  # Output menu items with icons
  printf "%s\x00icon\x1f%s\n" "$RANDOM_PIC_NAME" "$RANDOM_PIC"

  for pic_path in "${sorted_options[@]}"; do
    pic_name=$(basename "$pic_path")
    if [[ "$pic_name" =~ \.gif$ ]]; then
      cache_gif_image="$HOME/.cache/gif_preview/${pic_name}.png"
      if [[ ! -f "$cache_gif_image" ]]; then
        mkdir -p "$HOME/.cache/gif_preview"
        magick "$pic_path[0]" -resize 1920x1080 "$cache_gif_image"
      fi
      printf "%s\x00icon\x1f%s\n" "$pic_name" "$cache_gif_image"
    elif [[ "$pic_name" =~ \.(mp4|mkv|mov|webm|MP4|MKV|MOV|WEBM)$ ]]; then
      cache_preview_image="$HOME/.cache/video_preview/${pic_name}.png"
      if [[ ! -f "$cache_preview_image" ]]; then
        mkdir -p "$HOME/.cache/video_preview"
        ffmpeg -v error -y -i "$pic_path" -ss 00:00:01.000 -vframes 1 "$cache_preview_image"
      fi
      printf "%s\x00icon\x1f%s\n" "$pic_name" "$cache_preview_image"
    else
      printf "%s\x00icon\x1f%s\n" "$pic_name" "$pic_path"
    fi
  done
}

# Offer SDDM Simple Wallpaper Option (only for non-video wallpapers)
set_sddm_wallpaper() {
  sleep 1

  # Resolve SDDM themes directory (standard and NixOS path)
  local sddm_themes_dir=""
  if [ -d "/usr/share/sddm/themes" ]; then
    sddm_themes_dir="/usr/share/sddm/themes"
  elif [ -d "/run/current-system/sw/share/sddm/themes" ]; then
    sddm_themes_dir="/run/current-system/sw/share/sddm/themes"
  fi

  [ -z "$sddm_themes_dir" ] && return 0

  local sddm_simple="$sddm_themes_dir/simple_sddm_2"

  # Only prompt if theme exists and its Backgrounds directory is writable
  if [ -d "$sddm_simple" ] && [ -w "$sddm_simple/Backgrounds" ]; then

    # Check if yad is running to avoid multiple notifications
    if pidof yad >/dev/null; then
      killall yad
    fi

    if yad --info --text="Set current wallpaper as SDDM background?\n\nNOTE: This only applies to SIMPLE SDDM v2 Theme" \
      --text-align=left \
      --title="SDDM Background" \
      --timeout=5 \
      --timeout-indicator=right \
      --button="yes:0" \
      --button="no:1"; then

      # Check if terminal exists
      if ! command -v "$terminal" &>/dev/null; then
        notify-send -i "$iDIR/error.png" "Missing $terminal" "Install $terminal to enable setting of wallpaper background"
        exit 1
      fi

      exec "$SCRIPTSDIR/sddm_wallpaper.sh" --normal

    fi
  fi
}

modify_startup_config() {
  local selected_file="$1"
  local startup_config="$HOME/.config/hypr/UserConfigs/Startup_Apps.conf"

  # Check if it's a live wallpaper (video)
  if [[ "$selected_file" =~ \.(mp4|mkv|mov|webm)$ ]]; then
    # For video wallpapers:
    sed -i '/^\s*exec-once\s*=\s*swww-daemon\s*--format\s*xrgb\s*$/s/^/\#/' "$startup_config"
    sed -i '/^\s*#\s*exec-once\s*=\s*mpvpaper\s*.*$/s/^#\s*//;' "$startup_config"

    # Update the livewallpaper variable with the selected video path (using $HOME)
    selected_file="${selected_file/#$HOME/\$HOME}" # Replace /home/user with $HOME
    sed -i "s|^\$livewallpaper=.*|\$livewallpaper=\"$selected_file\"|" "$startup_config"

    echo "Configured for live wallpaper (video)."
  else
    # For image wallpapers:
    sed -i '/^\s*#\s*exec-once\s*=\s*swww-daemon\s*--format\s*xrgb\s*$/s/^\s*#\s*//;' "$startup_config"

    sed -i '/^\s*exec-once\s*=\s*mpvpaper\s*.*$/s/^/\#/' "$startup_config"

    echo "Configured for static wallpaper (image)."
  fi
}

# Apply Image Wallpaper
apply_image_wallpaper() {
  local image_path="$1"

  echo "[DEBUG FUNC] apply_image_wallpaper START with path: $image_path" | tee -a /tmp/wallpaper_debug.log

  kill_wallpaper_for_image

  if ! pgrep -x "swww-daemon" >/dev/null; then
    echo "[DEBUG FUNC] Starting swww-daemon..." | tee -a /tmp/wallpaper_debug.log
    swww-daemon --format xrgb &
    sleep 1
  fi

  echo "[DEBUG FUNC] Running: swww img -o $focused_monitor $image_path with transition params" | tee -a /tmp/wallpaper_debug.log

  if swww img -o "$focused_monitor" "$image_path" "${SWWW_PARAMS[@]}" 2>&1 | tee -a /tmp/wallpaper_debug.log; then
    echo "[DEBUG FUNC] swww img SUCCEEDED" | tee -a /tmp/wallpaper_debug.log
  else
    echo "[DEBUG FUNC] swww img FAILED with exit code $?" | tee -a /tmp/wallpaper_debug.log
  fi

  # Copy wallpaper for hyprlock
  cp -f "$image_path" "$wallpaper_current"

  # Run additional scripts (pass the image path to avoid cache race conditions)
  "$SCRIPTSDIR/WallustSwww.sh" "$image_path"
  sleep 2
  "$SCRIPTSDIR/Refresh.sh"
  sleep 1

  set_sddm_wallpaper
  echo "[DEBUG] apply_image_wallpaper completed" >> /tmp/wallpaper_debug.log
}

apply_video_wallpaper() {
  local video_path="$1"

  # Check if mpvpaper is installed
  if ! command -v mpvpaper &>/dev/null; then
    notify-send -i "$iDIR/error.png" "E-R-R-O-R" "mpvpaper not found"
    return 1
  fi
  kill_wallpaper_for_video

  # Apply video wallpaper using mpvpaper
  mpvpaper '*' -o "load-scripts=no no-audio --loop" "$video_path" &
}

# Main function
main() {
  # First run menu to calculate row number for last selection
  menu > /tmp/rofi_menu_$$

  selected_row=$(cat "$HOME/.cache/hypr/wallpaper_selected_row" 2>/dev/null || echo "0")

  # Build rofi command with -selected-row parameter to position cursor
  # Properly quote the theme override to handle curly braces
  rofi_command="rofi -i -dmenu -config $rofi_theme -theme-str '$rofi_override' -selected-row $selected_row"

  # Show menu and get choice (using file instead of command substitution to preserve null bytes)
  choice=$(cat /tmp/rofi_menu_$$ | eval "$rofi_command")
  rm -f /tmp/rofi_menu_$$

  # Debug: log what rofi returned
  echo "[DEBUG] Raw choice from rofi: '$choice'" >> /tmp/wallpaper_debug.log

  choice=$(echo "$choice" | xargs)
  RANDOM_PIC_NAME=$(echo "$RANDOM_PIC_NAME" | xargs)

  # Debug: log cleaned choice
  echo "[DEBUG] After xargs: '$choice'" >> /tmp/wallpaper_debug.log

  if [[ -z "$choice" ]]; then
    echo "No choice selected. Exiting."
    exit 0
  fi

  # Handle random selection correctly
  if [[ "$choice" == "$RANDOM_PIC_NAME" ]]; then
    choice=$(basename "$RANDOM_PIC")
  fi

  choice_basename=$(basename "$choice" | sed 's/\(.*\)\.[^.]*$/\1/')
  echo "[DEBUG] Choice basename: '$choice_basename'" >> /tmp/wallpaper_debug.log

  # Search for the selected file in the wallpapers directory, including subdirectories
  selected_file=$(find "$wallDIR" -iname "$choice_basename.*" -print -quit)

  echo "[DEBUG] Search pattern: $choice_basename.* in $wallDIR" >> /tmp/wallpaper_debug.log
  echo "[DEBUG] Found file: '$selected_file'" >> /tmp/wallpaper_debug.log

  if [[ -z "$selected_file" ]]; then
    echo "File not found. Selected choice: $choice" | tee -a /tmp/wallpaper_debug.log
    exit 1
  fi

  # Save selected wallpaper name to cache for next time
  echo "$choice" > "$wallpaper_cache_file"
  echo "[DEBUG] Saved to cache: '$choice'" >> /tmp/wallpaper_debug.log

  # Modify the Startup_Apps.conf file based on wallpaper type
  modify_startup_config "$selected_file"

  # **CHECK FIRST** if it's a video or an image **before calling any function**
  echo "[DEBUG] About to check file type: '$selected_file'" | tee -a /tmp/wallpaper_debug.log

  if [[ "$selected_file" =~ \.(mp4|mkv|mov|webm|MP4|MKV|MOV|WEBM)$ ]]; then
    echo "[DEBUG] File is VIDEO" | tee -a /tmp/wallpaper_debug.log
    apply_video_wallpaper "$selected_file"
  else
    echo "[DEBUG] File is IMAGE, calling apply_image_wallpaper with: '$selected_file'" | tee -a /tmp/wallpaper_debug.log
    apply_image_wallpaper "$selected_file"
    echo "[DEBUG] apply_image_wallpaper returned" | tee -a /tmp/wallpaper_debug.log
  fi
  echo "[DEBUG] Script completed" | tee -a /tmp/wallpaper_debug.log
}

# Check if rofi is already running
if pidof rofi >/dev/null; then
  pkill rofi
fi

main