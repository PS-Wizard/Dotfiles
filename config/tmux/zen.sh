#!/usr/bin/bash
# Tmux Zen Mode - Center every single-pane window in the session.
# Usage: zen.sh [width]
# Internal: zen.sh apply-window WINDOW_ID

MODE="toggle"
CENTER_WIDTH="120"
TARGET=""

case "${1:-}" in
    apply-window)
        MODE="apply-window"
        TARGET="$2"
        ;;
    "") ;;
    *[!0-9]*)
        tmux display-message "Zen mode: width must be a number"
        exit 1
        ;;
    *) CENTER_WIDTH="$1" ;;
esac

if [ "$MODE" = "apply-window" ]; then
    SESSION=$(tmux display-message -p -t "$TARGET" '#{session_id}')
else
    TARGET=$(tmux display-message -p '#{window_id}')
    SESSION=$(tmux display-message -p '#{session_id}')
fi

SCRIPT_PATH=$(readlink -f "$0")

spacer_panes() {
    tmux list-panes -t "$1" -F '#{pane_id} #{@zen_spacer}' | awk '$2 == 1 { print $1 }'
}

apply_window() {
    window=$1

    [ "$(spacer_panes "$window" | wc -l)" -eq 2 ] && return 0

    pane_count=$(tmux display-message -p -t "$window" '#{window_panes}')
    [ "$pane_count" -eq 1 ] || return 1

    window_width=$(tmux display-message -p -t "$window" '#{window_width}')
    total_margin=$((window_width - CENTER_WIDTH - 2))
    [ "$total_margin" -ge 10 ] || return 1

    pane=$(tmux list-panes -t "$window" -F '#{pane_id}')
    left_width=$((total_margin / 2))
    right_width=$((total_margin - left_width))

    spacer_command='tmux set-option -pt "$TMUX_PANE" remain-on-exit on; tmux set-option -pt "$TMUX_PANE" remain-on-exit-format ""'
    right=$(tmux split-window -hdt "$pane" -P -F '#{pane_id}' "$spacer_command")
    left=$(tmux split-window -hbdt "$pane" -P -F '#{pane_id}' "$spacer_command")

    for spacer in "$left" "$right"; do
        tmux set-option -pt "$spacer" @zen_spacer 1
        tmux select-pane -dt "$spacer" -T zen-spacer
    done

    tmux select-layout -t "$window" even-horizontal >/dev/null
    tmux resize-pane -t "$left" -x "$left_width"
    tmux resize-pane -t "$right" -x "$right_width"
}

enable_zen() {
    tmux set-option -t "$SESSION" @zen_mode 1
    tmux set-option -t "$SESSION" @zen_width "$CENTER_WIDTH"
    tmux set-hook -t "$SESSION" 'after-new-window[9000]' \
        "run-shell '$SCRIPT_PATH apply-window #{window_id}'"

    skipped=0
    while read -r window; do
        apply_window "$window" || skipped=$((skipped + 1))
    done < <(tmux list-windows -t "$SESSION" -F '#{window_id}')

    if [ "$skipped" -gt 0 ]; then
        tmux display-message "Zen mode on; skipped $skipped split or narrow window(s)"
    else
        tmux display-message "Zen mode on for this session"
    fi
}

disable_zen() {
    tmux set-hook -u -t "$SESSION" 'after-new-window[9000]'
    tmux set-option -u -t "$SESSION" @zen_mode
    tmux set-option -u -t "$SESSION" @zen_width

    while read -r window; do
        while read -r spacer; do
            [ -n "$spacer" ] && tmux kill-pane -t "$spacer"
        done < <(spacer_panes "$window")
    done < <(tmux list-windows -t "$SESSION" -F '#{window_id}')

    tmux display-message "Zen mode off for this session"
}

if [ "$MODE" = "apply-window" ]; then
    [ "$(tmux show-option -qv -t "$SESSION" @zen_mode)" = 1 ] || exit 0
    CENTER_WIDTH=$(tmux show-option -qv -t "$SESSION" @zen_width)
    apply_window "$TARGET"
elif [ "$(tmux show-option -qv -t "$SESSION" @zen_mode)" = 1 ]; then
    disable_zen
else
    enable_zen
fi
