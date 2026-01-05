#!/bin/bash
# Wallpaper and Alacritty opacity controller
# Usage: wallpaper-switcher.sh [next|prev|random|opacity-up|opacity-down]

export PATH="/usr/local/bin:/usr/bin:/bin"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"

WALLPAPER_DIR="$HOME/.config/niri/wallpapers/"
CACHE_FILE="$HOME/.cache/current_wallpaper"
ALACRITTY_CONFIG="$HOME/.config/alacritty/alacritty.toml"
TRANSITION="fade"
DURATION="0.5"
OPACITY_STEP=0.25

# Create cache dir if it doesn't exist
mkdir -p "$(dirname "$CACHE_FILE")"

# Get all wallpapers
mapfile -t WALLPAPERS < <(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \) | sort)

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    echo "No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

# Get current wallpaper index
get_current_index() {
    if [ -f "$CACHE_FILE" ]; then
        CURRENT=$(cat "$CACHE_FILE")
        for i in "${!WALLPAPERS[@]}"; do
            if [ "${WALLPAPERS[$i]}" = "$CURRENT" ]; then
                echo "$i"
                return
            fi
        done
    fi
    echo "0"
}

# Set wallpaper
set_wallpaper() {
    local wallpaper="$1"
    swww img "$wallpaper" --transition-type "$TRANSITION" --transition-duration "$DURATION"
    echo "$wallpaper" > "$CACHE_FILE"
    echo "Set wallpaper: $(basename "$wallpaper")"
}

# Get current opacity
get_opacity() {
    grep -E "^opacity\s*=" "$ALACRITTY_CONFIG" | sed -E 's/.*=\s*([0-9.]+).*/\1/'
}

# Set opacity
set_opacity() {
    local new_opacity="$1"
    
    # Clamp between 0.0 and 1.0
    new_opacity=$(awk -v val="$new_opacity" 'BEGIN {
        if (val < 0.0) val = 0.0
        if (val > 1.0) val = 1.0
        printf "%.2f", val
    }')
    
    # Update config file
    sed -i "s/^opacity\s*=.*/opacity = $new_opacity/" "$ALACRITTY_CONFIG"
    
    echo "Set Alacritty opacity: $new_opacity"
}

CURRENT_INDEX=$(get_current_index)

case "$1" in
    next)
        NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#WALLPAPERS[@]} ))
        set_wallpaper "${WALLPAPERS[$NEXT_INDEX]}"
        ;;
    prev)
        PREV_INDEX=$(( (CURRENT_INDEX - 1 + ${#WALLPAPERS[@]}) % ${#WALLPAPERS[@]} ))
        set_wallpaper "${WALLPAPERS[$PREV_INDEX]}"
        ;;
    random)
        RANDOM_INDEX=$((RANDOM % ${#WALLPAPERS[@]}))
        set_wallpaper "${WALLPAPERS[$RANDOM_INDEX]}"
        ;;
    opacity-up)
        CURRENT_OPACITY=$(get_opacity)
        NEW_OPACITY=$(awk -v curr="$CURRENT_OPACITY" -v step="$OPACITY_STEP" 'BEGIN {printf "%.2f", curr + step}')
        set_opacity "$NEW_OPACITY"
        ;;
    opacity-down)
        CURRENT_OPACITY=$(get_opacity)
        NEW_OPACITY=$(awk -v curr="$CURRENT_OPACITY" -v step="$OPACITY_STEP" 'BEGIN {printf "%.2f", curr - step}')
        set_opacity "$NEW_OPACITY"
        ;;
    *)
        # Default: set first wallpaper or current
        if [ -f "$CACHE_FILE" ]; then
            set_wallpaper "$(cat "$CACHE_FILE")"
        else
            set_wallpaper "${WALLPAPERS[0]}"
        fi
        ;;
esac
