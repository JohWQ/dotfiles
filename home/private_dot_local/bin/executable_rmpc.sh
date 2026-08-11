#!/usr/bin/env bash

# Check if current terminal is Kitty
if [ "$TERM" != "xterm-kitty" ]; then
    nohup kitty bash "$0" "$@" >/dev/null 2>&1 &
    disown
    exit 0
fi
# EVERYTHING BELOW THIS LINE EXECUTES ONLY INSIDE KITTY

systemctl --user start mpd mpd-mpris
rmpc && systemctl --user stop mpd mpd-mpris
