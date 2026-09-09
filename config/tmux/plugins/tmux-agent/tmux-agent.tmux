# tmux-agent loader; safe to source repeatedly.
unbind Enter
bind Enter command-prompt -p "Agent marker (blank unmarks):" -I "#{@agent_marker}" "run-shell '~/.config/tmux/plugins/tmux-agent/bin/tmux-agent --pane #{pane_id} mark \"%%\"'"
