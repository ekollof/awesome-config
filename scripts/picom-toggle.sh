#!/bin/sh

# Toggle picom compositor on/off

if pgrep -x picom > /dev/null; then
    pkill -x picom
else
    picom -b --config "$HOME/.config/awesome/picom.conf" &
fi
