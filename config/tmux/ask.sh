#!/usr/bin/env bash
# Ask a question, then send it to a web search or AI chat site.
# Step 1: type the question. Step 2: pick the target (ChatGPT is default).

COLORS="--color=bg:-1,bg+:-1,prompt:#f6c177,pointer:#eb6f92,header:#6e6a86"

# Step 1: the question. No list, only the query line.
query=$(fzf --print-query \
    --prompt="  ask ❯ " \
    --header="enter: continue" \
    $COLORS < /dev/null)
[ -n "$query" ] || exit 0

# Step 2: the target. ChatGPT sits on the second row and starts selected.
target=$(printf 'Google\nChatGPT\nClaude\n' | fzf \
    --prompt="  send to ❯ " \
    --bind='load:pos(2)' \
    --header="enter: open in Zen" \
    $COLORS)
[ -n "$target" ] || exit 0

encoded=$(jq -rn --arg q "$query" '$q|@uri')

case "$target" in
    Google)  url="https://www.google.com/search?q=$encoded" ;;
    ChatGPT) url="https://chatgpt.com/?q=$encoded" ;;
    Claude)  url="https://claude.ai/new?q=$encoded" ;;
    *)       exit 0 ;;
esac

export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/run/user/$UID}"
export DBUS_SESSION_BUS_ADDRESS="${DBUS_SESSION_BUS_ADDRESS:-unix:path=$XDG_RUNTIME_DIR/bus}"

if command -v zen-browser >/dev/null 2>&1; then
    zen-browser --new-tab "$url" >/dev/null 2>&1
else
    xdg-open "$url" >/dev/null 2>&1
fi
