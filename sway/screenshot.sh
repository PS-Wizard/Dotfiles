#!/bin/bash

# Prompt for screenshot type
choice=$(echo -e "area\nfull" | bemenu -p "Screenshot:")

# Exit if nothing selected
[ -z "$choice" ] && exit 0

# Ask to save FIRST
save=$(echo -e "y\nn" | bemenu -p "Save screenshot?")

# Exit if nothing selected
[ -z "$save" ] && exit 0

# NOW take screenshot based on choice
if [ "$choice" = "area" ]; then
    grim -g "$(slurp)" /tmp/screenshot.png
elif [ "$choice" = "full" ]; then
    grim /tmp/screenshot.png
fi

# Check if screenshot was taken successfully
if [ ! -f /tmp/screenshot.png ]; then
    echo "Screenshot failed or cancelled"
    exit 1
fi

if [ "$save" = "y" ]; then
    # Save with timestamp filename
    filename="$HOME/screenshot_$(date +%H-%M-%S).png"
    mv /tmp/screenshot.png "$filename"
    echo "Saved to $filename"
else
    # Copy to clipboard
    wl-copy --type image/png < /tmp/screenshot.png
    rm /tmp/screenshot.png
    echo "Copied to clipboard"
fi
