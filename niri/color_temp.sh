#!/bin/bash

# File to store current temperature
TEMP_FILE="/tmp/color_temp_current"
DEFAULT_TEMP=4500

# Get current temperature or use default
get_temp() {
    if [ -f "$TEMP_FILE" ]; then
        cat "$TEMP_FILE"
    else
        echo $DEFAULT_TEMP
    fi
}

# Save temperature to file
save_temp() {
    echo "$1" > "$TEMP_FILE"
}

# Kill existing gammastep processes
kill_gammastep() {
    pkill -x gammastep 2>/dev/null
}

# Apply temperature
apply_temp() {
    local temp=$1
    kill_gammastep
    gammastep -O "$temp" &
}

# Main logic
case "$1" in
    sub)
        current=$(get_temp)
        new=$((current + 500))
        # Cap at reasonable max (10000K is very blue)
        if [ $new -gt 10000 ]; then
            new=10000
        fi
        save_temp $new
        apply_temp $new
        echo "Color temperature: ${new}K"
        ;;
    add)
        current=$(get_temp)
        new=$((current - 500))
        # Cap at reasonable min (1000K is very warm)
        if [ $new -lt 1000 ]; then
            new=1000
        fi
        save_temp $new
        apply_temp $new
        echo "Color temperature: ${new}K"
        ;;
    reset)
        save_temp $DEFAULT_TEMP
        apply_temp $DEFAULT_TEMP
        echo "Color temperature reset to ${DEFAULT_TEMP}K"
        ;;
    *)
        echo "Usage: $0 {add|sub|reset}"
        echo "Current temperature: $(get_temp)K"
        exit 1
        ;;
esac
