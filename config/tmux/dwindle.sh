#!/usr/bin/env bash
# Dwindle-style pane spawn (like Hyprland).
#
# Every pane remembers the direction of the split that created it
# (stored in the per-pane option @dwindle). A new pane splits the
# focused pane in the OPPOSITE direction, so the layout alternates
# vertical / horizontal / vertical / ... as you move focus.
#
# - original (unset) pane  -> vertical split  (new pane to the right)
# - created by vertical    -> horizontal split (new pane below)
# - created by horizontal  -> vertical split  (new pane to the right)

PANE=$(tmux display-message -p '#{pane_id}')
CDIR=$(tmux display-message -p -t "$PANE" '#{pane_current_path}')
DIR=$(tmux show-options -p -t "$PANE" -qv @dwindle)

case "$DIR" in
  vertical)
    tmux split-window -v -c "$CDIR"
    NEWDIR=horizontal
    ;;
  horizontal)
    tmux split-window -h -c "$CDIR"
    NEWDIR=vertical
    ;;
  *)
    tmux split-window -h -c "$CDIR"
    NEWDIR=vertical
    ;;
esac

tmux set-option -p -t "$(tmux display-message -p '#{pane_id}')" @dwindle "$NEWDIR"
