#!/bin/bash

# Toggle picom compositor on/off

if pgrep -x picom > /dev/null; then
    killall picom
else
    picom -b --config "$HOME/.config/awesome/picom.conf" &
fi
