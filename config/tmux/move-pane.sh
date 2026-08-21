#!/usr/bin/env bash
# Move the focused pane in the given direction (like a tiling WM).
# If a neighbor exists that way → swap positions.
# If not (edge case) → break out and rejoin in that direction,
# converting the split orientation (side-by-side ↔ stacked).

DIR="$1"
CUR=$(tmux display-message -p '#{pane_id}')

case "$DIR" in
  left)
    if [ "$(tmux display-message -p '#{pane_at_left}')" = "1" ]; then
      tmux break-pane -d -s "$CUR"
      tmux join-pane -d -b -h -s "$CUR" -t :.1
    else
      tmux select-pane -L
      tmux swap-pane -d -s "$CUR" -t "$(tmux display-message -p '#{pane_id}')"
    fi
    ;;
  right)
    if [ "$(tmux display-message -p '#{pane_at_right}')" = "1" ]; then
      tmux break-pane -d -s "$CUR"
      tmux join-pane -d -h -s "$CUR" -t :.1
    else
      tmux select-pane -R
      tmux swap-pane -d -s "$CUR" -t "$(tmux display-message -p '#{pane_id}')"
    fi
    ;;
  up)
    if [ "$(tmux display-message -p '#{pane_at_top}')" = "1" ]; then
      tmux break-pane -d -s "$CUR"
      tmux join-pane -d -b -s "$CUR" -t :.1
    else
      tmux select-pane -U
      tmux swap-pane -d -s "$CUR" -t "$(tmux display-message -p '#{pane_id}')"
    fi
    ;;
  down)
    if [ "$(tmux display-message -p '#{pane_at_bottom}')" = "1" ]; then
      tmux break-pane -d -s "$CUR"
      tmux join-pane -d -s "$CUR" -t :.1
    else
      tmux select-pane -D
      tmux swap-pane -d -s "$CUR" -t "$(tmux display-message -p '#{pane_id}')"
    fi
    ;;
esac
