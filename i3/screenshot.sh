#!/bin/bash
SAVE_DIR="$HOME/Pictures"

choice=$(echo -e "Full\nArea" | dmenu -p "Screenshot mode:")

if [[ "$choice" == "Full" ]]; then
    save_or_copy=$(echo -e "Save\nCopy" | dmenu -p "Save or Copy?")

    if [[ "$save_or_copy" == "Save" ]]; then
        maim "$SAVE_DIR/screenshot-$(date +%Y%m%d%H%M%S).png"
    else
        maim | xclip -selection clipboard -t image/png
    fi

elif [[ "$choice" == "Area" ]]; then
    save_or_copy=$(echo -e "Save\nCopy" | dmenu -p "Save or Copy?")

    # Use maim -s for selection mode
    if [[ "$save_or_copy" == "Save" ]]; then
        maim -s "$SAVE_DIR/screenshot-$(date +%Y%m%d%H%M%S).png"
    else
        maim -s | xclip -selection clipboard -t image/png
    fi
fi
