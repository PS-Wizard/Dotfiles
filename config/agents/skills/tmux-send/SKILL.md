---
name: tmux-send
description: >-
  Paste text, send text, or type into a marked tmux pane that is not an AI
  agent. Use when the user asks to paste or type into a plain shell, ssh
  session, editor, or REPL pane.
---

# tmux-send

`tmux-send` pastes text into a pane marked with `@agent_marker`.
It reuses the same marker `tmux-agent` uses. Use it for plain panes
that are not AI agents: shell, ssh, editor, REPL.

Default is paste only with no Enter. `--submit` adds Enter.

```bash
tmux-send list
tmux-send send MARKER "text"
echo text | tmux-send send MARKER
tmux-send send MARKER --submit "cmd"
```

Always use `tmux-send`, never `tmux send-keys` for text bodies.

## Delivery

Delivery is a lone C-u, a 0.1s pause, one bracketed paste via
load-buffer and paste-buffer, another 0.1s pause, then an
optional Enter only when `--submit` is set.

## Failure modes

`tmux-send` fails clearly on invalid marker, no pane, ambiguous
marker, dead pane, or when the target pane is in a tmux mode.
