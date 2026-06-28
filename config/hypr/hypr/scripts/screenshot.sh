#!/bin/sh
set -eu

choice=$(printf 'Copy Screenshot\nSave Screenshot\n' | bemenu -p 'Screenshot')
[ -n "$choice" ] || exit 0

selection=$(slurp)
[ -n "$selection" ] || exit 0

case "$choice" in
  'Copy Screenshot')
    grim -g "$selection" - | wl-copy --type image/png
    ;;
  'Save Screenshot')
    mkdir -p "$HOME/Pictures"
    file="$HOME/Pictures/$(date +'%Y-%m-%d_%H-%M-%S').png"
    grim -g "$selection" "$file"
    ;;
  *)
    exit 1
    ;;
esac
