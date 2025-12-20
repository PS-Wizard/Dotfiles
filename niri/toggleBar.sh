#!/bin/bash

if pgrep -x "yambar" > /dev/null; then
    pkill -x yambar
else
    yambar &
fi
