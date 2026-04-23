#!/bin/sh
# Lock the screen using i3lock-color (installed as 'i3lock').
# Uses the current wallust wallpaper so the lock screen matches the desktop.

COLORS_FILE="$HOME/.cache/wal/awesome-colors.lua"

# Extract wallpaper path from the Lua colors file.
# Line format:  wallpaper   = "/path/to/image.jpg",
WALLPAPER=""
if [ -f "$COLORS_FILE" ]; then
    WALLPAPER=$(grep 'wallpaper' "$COLORS_FILE" | sed 's/.*= *"\(.*\)".*/\1/')
fi

if [ -n "$WALLPAPER" ] && [ -f "$WALLPAPER" ]; then
    exec i3lock --nofork \
        --image "$WALLPAPER" \
        --fill \
        --clock \
        --indicator \
        --time-font="BerkeleyMono Nerd Font" \
        --date-font="BerkeleyMono Nerd Font" \
        --layout-font="BerkeleyMono Nerd Font" \
        --verif-font="BerkeleyMono Nerd Font" \
        --wrong-font="BerkeleyMono Nerd Font" \
        --time-color=ffffffff \
        --date-color=ffffffff \
        --ring-color=ffffff44 \
        --keyhl-color=ffffffcc \
        --bshl-color=ff000088 \
        --separator-color=00000000 \
        --inside-color=00000066 \
        --line-color=00000000 \
        --verif-color=ffffffcc \
        --wrong-color=ff4444cc
else
    exec i3lock --nofork -c 000000
fi
