#!/usr/bin/env bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Simple bash script to check and will try to update your system

# Local Paths
iDIR="$HOME/.config/swaync/images"
SCRIPT_DIR="$HOME/.config/hypr/scripts"

# Get configured terminal (with fallback)
TERMINAL=$("$SCRIPT_DIR/get-terminal.sh" 2>/dev/null || echo "kitty")
if ! command -v "$TERMINAL" &> /dev/null; then
  TERMINAL="kitty"
fi

# Detect distribution and update accordingly
if command -v paru &> /dev/null || command -v yay &> /dev/null; then
  # Arch-based
  if command -v paru &> /dev/null; then
    $TERMINAL -T update paru -Syu
    notify-send -i "$iDIR/ja.png" -u low 'Arch-based system' 'has been updated.'
  else
    $TERMINAL -T update yay -Syu
    notify-send -i "$iDIR/ja.png" -u low 'Arch-based system' 'has been updated.'
  fi
elif command -v dnf &> /dev/null; then
  # Fedora-based
  $TERMINAL -T update sudo dnf update --refresh -y
  notify-send -i "$iDIR/ja.png" -u low 'Fedora system' 'has been updated.'
elif command -v apt &> /dev/null; then
  # Debian-based (Debian, Ubuntu, etc.)
  $TERMINAL -T update sudo apt update && sudo apt upgrade -y
  notify-send -i "$iDIR/ja.png" -u low 'Debian/Ubuntu system' 'has been updated.'
elif command -v zypper &> /dev/null; then
  # openSUSE-based
  $TERMINAL -T update sudo zypper dup -y
  notify-send -i "$iDIR/ja.png" -u low 'openSUSE system' 'has been updated.'
else
  # Unsupported distro
  notify-send -i "$iDIR/error.png" -u critical "Unsupported system" "This script does not support your distribution."
  exit 1
fi
