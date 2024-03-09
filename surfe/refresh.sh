#!/bin/bash


CHROMIUM_ID=$(xdotool search --name "Chromium" | tail -1)
xdotool windowactivate $CHROMIUM_ID

while true; do
    xdotool key ctrl+shift+r
    sleep 20
done
