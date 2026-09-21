#!/usr/bin/env bash
# Move the focused pane in the given direction (like a tiling WM).
#   Split window       -> swap the focused pane with the neighbour that way.
#   Single-pane window -> swap the whole window with its left/right neighbour.
#   Zen-mode spacers are ignored when counting panes.
# At an edge with no neighbour, nothing happens. Nothing is ever merged.
DIR="$1"
CUR=$(tmux display-message -p '#{pane_id}')

real=$(tmux list-panes -F '#{@zen_spacer}' | grep -vcx 1)
if [ "$real" -le 1 ]; then
  case "$DIR" in
    left)  step=-1 ;;
    right) step=1 ;;
    *)     exit 0 ;;
  esac

  win=$(tmux display-message -p '#{window_id}')
  mapfile -t wins < <(tmux list-windows -F '#{window_id}')
  for i in "${!wins[@]}"; do
    [ "${wins[$i]}" = "$win" ] && break
  done
  j=$((i + step))
  (( j < 0 || j >= ${#wins[@]} )) && exit 0

  tmux swap-window -s "$win" -t "${wins[$j]}"
  tmux select-window -t "$win"
  exit 0
fi

case "$DIR" in
  left)  edge='#{pane_at_left}';   move=-L ;;
  right) edge='#{pane_at_right}';  move=-R ;;
  up)    edge='#{pane_at_top}';    move=-U ;;
  down)  edge='#{pane_at_bottom}'; move=-D ;;
  *)     exit 0 ;;
esac

[ "$(tmux display-message -p "$edge")" = 1 ] && exit 0

tmux select-pane "$move"
tmux swap-pane -d -s "$CUR" -t "$(tmux display-message -p '#{pane_id}')"
