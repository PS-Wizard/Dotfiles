#!/bin/bash

current=$(tmux display-message -p '#S')
tmp=$(mktemp)

tmux list-sessions -F "#{session_name}" 2>/dev/null \
  | grep -v "^${current}$" \
  | fzf \
  --prompt="  " \
  --print-query \
  --bind="ctrl-d:execute(tmux kill-session -t {})+reload(tmux list-sessions -F '#{session_name}' 2>/dev/null | grep -v '^${current}$')" \
  --bind="ctrl-r:execute(bash -c 'old=\"\$1\"; printf \"rename %s → \" \"\$old\" > /dev/tty; IFS= read -r new < /dev/tty; [ -n \"\$new\" ] && tmux rename-session -t \"\$old\" \"\$new\"' _ {})+reload(tmux list-sessions -F '#{session_name}' 2>/dev/null | grep -v '^${current}$')" \
  --header="enter:switch  ctrl-r:rename  ctrl-d:kill  (type new name + enter to create)" \
  --color=bg:-1,bg+:-1,prompt:#f6c177,pointer:#eb6f92,header:#6e6a86 > "$tmp"

query=$(sed -n '1p' "$tmp")
selected=$(sed -n '2p' "$tmp")
rm -f "$tmp"

if [ -n "$selected" ]; then
  tmux switch-client -t "$selected"
elif [ -n "$query" ]; then
  tmux new-session -d -s "$query" && tmux switch-client -t "$query"
fi
