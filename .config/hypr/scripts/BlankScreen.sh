#!/usr/bin/env bash
# Blank all displays via Hyprland DPMS. Waits briefly first so the key
# release of the shortcut that triggered this (SUPER+CTRL+Insert, or
# Enter on the "! Blank screen" launcher entry) has landed before
# DPMS goes off — otherwise misc.key_press_enables_dpms would see the
# release and wake the screens immediately. Same reason for the sleep
# vs mouse_move_enables_dpms if the pointer twitches at all.
#
# Waking back up: any key press or mouse movement (both handled by
# lua/core/config.lua: misc.key_press_enables_dpms / mouse_move_enables_dpms).
sleep 0.5
hyprctl dispatch 'hl.dsp.dpms({ action = "off" })' >/dev/null
