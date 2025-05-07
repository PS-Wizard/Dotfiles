#!/bin/bash
# Set the screenshot directory
SAVE_DIR="$HOME/Pictures"

# Ask the user if they want to capture the entire screen or a selection
choice=$(echo -e "entire\nselection" | bemenu --prompt "Capture mode: ")

# If the user selects "entire"
if [[ "$choice" == "entire" ]]; then
    # Get available displays using swaymsg
    display=$(swaymsg -t get_outputs | jq -r '.[].name' | bemenu --prompt "Select display: ")

    if [[ -n "$display" ]]; then
        # Capture the screenshot for the selected display and save it
        grim -o "$display" "$SAVE_DIR/screenshot-$(date +%Y%m%d%H%M%S).png"
    fi

# If the user selects "selection"
elif [[ "$choice" == "selection" ]]; then
    # Ask if the user wants to save the selection
    save=$(echo -e "y\nn" | bemenu --prompt "Save screenshot? ")

    # Capture the selection area only once
    selection=$(slurp)

    # Copy the screenshot of the selected area to the clipboard
    grim -g "$selection" - | wl-copy -t "image/png"

    # If the user chose to save, save the screenshot to disk
    if [[ "$save" == "y" ]]; then
        grim -g "$selection" "$SAVE_DIR/screenshot-$(date +%Y%m%d%H%M%S).png"
    fi
fi

