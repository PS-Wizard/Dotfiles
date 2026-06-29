#!/bin/sh
SHADER="/home/wizard/.config/hypr/monochrome.frag"

if hyprctl getoption decoration:screen_shader | grep -Fq "$SHADER"; then
    hyprctl eval "hl.config({decoration={screen_shader=''}})"
else
    hyprctl eval "hl.config({decoration={screen_shader='$SHADER'}})"
fi
