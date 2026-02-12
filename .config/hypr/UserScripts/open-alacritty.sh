#!/usr/bin/env sh
# Try to create a new window in an existing Alacritty; if no daemon is running, start Alacritty.
# With arguments (e.g. -e cmd), always run alacritty with those args.
[ $# -gt 0 ] && exec alacritty "$@"
alacritty msg create-window 2>/dev/null || exec alacritty
