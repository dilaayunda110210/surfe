#!/bin/bash

CHROMIUM_ID=$(xdotool search --name "Chromium" | tail -1)

yad --form \
    --title="Surfe Makro" --borders=10 --columns=5 --row=1\
    --field="!edit-clear-rtl-symbolic":BTN "sudo pkill -f macro.sh" \
    --field="!screen-shared-symbolic":BTN "./macro.sh" \
    --field="!edit-clear-rtl-symbolic":BTN "sudo pkill -f macro.sh" \
    --field="!rotation-allowed-symbolic":BTN "./refresh.sh" \
    --field="!media-playback-start-symbolic":BTN "cd /config/surfe && git pull" \
    --no-buttons
