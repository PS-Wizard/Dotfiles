#!/bin/bash
# Check current bar mode and toggle
current_mode=$(i3-msg -t get_bar_config bar-0 | jq -r '.mode')

if [ "$current_mode" = "dock" ]; then
    i3-msg bar mode invisible
else
    i3-msg bar mode dock
fi

