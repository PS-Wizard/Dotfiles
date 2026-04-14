#!/bin/bash

current=$(tmux display-message -p '#S')
tmp=$(mktemp)

tmux list-sessions -F "#{session_name}" 2>/dev/null \
  | grep -v "^${current}$" \
  | fzf \
  --prompt="  " \
  --print-query \
  --bind="ctrl-d:execute(tmux kill-session -t {})+reload(tmux list-sessions -F '#{session_name}' 2>/dev/null | grep -v '^${current}$')" \
  --header="enter:switch  ctrl-d:kill  (type new name + enter to create)" \
  --color=bg:-1,bg+:-1,border:#31748f,prompt:#f6c177,pointer:#eb6f92,header:#6e6a86 \
  --border=rounded > "$tmp"

query=$(sed -n '1p' "$tmp")
selected=$(sed -n '2p' "$tmp")
rm -f "$tmp"

if [ -n "$selected" ]; then
  tmux switch-client -t "$selected"
elif [ -n "$query" ]; then
  tmux new-session -d -s "$query" && tmux switch-client -t "$query"
fi
