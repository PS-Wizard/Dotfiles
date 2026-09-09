---
name: tmux-agent
description: >-
  Message and delegate tasks between AI agents in tmux panes. Use when the user
  asks to contact, message, delegate to, reply to, discover, mark, or check
  messages from another tmux agent pane.
---

# tmux-agent

`tmux-agent` stores message bodies as files. It types only a generated `tmux-agent read ID` notification into the target pane, never the message body. It works only inside the same tmux server and local Unix user. State lives under `/tmp/tmux-agent-$UID`, separated by tmux server PID.

## Markers

- `Prefix+Enter` opens a prompt to mark or rename the current pane. Blank input unmarks it.
- Markers belong to panes and survive pane moves and break/join operations.
- Marker names: lowercase `[a-z0-9._-]`, start alphanumeric, max 64 chars.

```bash
tmux-agent mark my-agent      # set marker on current pane
tmux-agent unmark             # remove marker
tmux-agent whoami             # show this pane's marker (or "unmarked")
tmux-agent list               # all marked panes (* = current pane)
```

## Send

Always use `tmux-agent send`, never `tmux send-keys` for message bodies.

```bash
tmux-agent send other-agent "Quick question about auth.go"
```

For multiline delegation, pipe a single-quoted heredoc. Never use `eval`:

```bash
tmux-agent send other-agent <<'EOF'
Refactor the login handler in auth.go.
Expected: tests pass, no API change.
Reply here when done with a short summary.
EOF
```

Include concrete context, files, expected result, and how to report completion. Preserve the user's intent.

## Receive

Run `tmux-agent inbox` when an agent starts or resumes inside tmux.
`inbox`, `read`, and `ack` use the process's own `TMUX_PANE`. Client focus does not change `TMUX_PANE`.

When a terminal prompt receives `tmux-agent read SAFE_ID`, run that command immediately. Act on the returned message. Reply to its `From` marker when useful. Ack only after the message is handled.

```bash
tmux-agent inbox               # list unread message IDs for this pane
tmux-agent read m1234-5678-9   # print message body
tmux-agent ack m1234-5678-9    # delete after handling
```

`tmux-agent inbox` being empty means the current pane has no unread messages. It does not mean all agent panes are empty.

## Reply

```bash
tmux-agent send sender-marker "Done. See auth.go:42. Please review."
```

## Workflow

1. Run `tmux-agent list` to find the target marker.
2. Run `tmux-agent send MARKER "..."` to deliver a task or reply.
3. The recipient runs `tmux-agent read ID`, acts, and replies when needed.
4. Run `tmux-agent ack ID` after the message is handled.
