#!/bin/bash

# Static list of languages you care about
LANGUAGES=(
    "js"
    "rust"
    "c"
    "go"
    "lua"
)

# Select language with fzf
LANG=$(printf '%s\n' "${LANGUAGES[@]}" | fzf --prompt="Select language: " --height=40% --border)

# Exit if no language selected
[[ -z "$LANG" ]] && exit 0

# Get available queries for the selected language
QUERY=$(curl -s "cht.sh/$LANG/:list" | fzf --prompt="Select query (or Esc for full cheatsheet): " --height=40% --border)

# Build the URL
if [[ -z "$QUERY" ]]; then
    URL="cht.sh/$LANG"
else
    URL="cht.sh/$LANG/$QUERY"
fi

curl -s "$URL" | less -R
