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

### Delivery behavior

- `send` saves the message first, prints its ID, and keeps it in the inbox no matter what happens next.
- Notifications are serialized per target pane with a process-lifetime `flock` lock, so concurrent sends cannot interleave text and Enter. If `flock` is missing, `send` fails clearly after saving, without a hang; the message stays in the inbox.
- Delivery is three separate input events under the lock: `C-u` alone (clears partial input), a 0.1 s foreground pause, one literal bracketed-paste sequence framing only `tmux-agent read ID` (`ESC[200~` + command + `ESC[201~`) with no Enter, another 0.1 s foreground pause, then one `Enter` alone. The message body is never pasted. The pause is a tuned constant (`notify_pause = 0.1 s`), not a configurable timeout: Cursor's CLI drops text that arrives in the same PTY input chunk as `C-u`, and it mis-submits when Enter trails the bracketed-paste terminator in the same chunk, so each PTY input event is kept separate.
- Before the paste and again before `Enter`, `send` rechecks that the exact pane is live and not in a tmux mode. If the pane is gone or a mode is active, it sends no further keys and fails naming the phase that failed.
- If the target pane starts in copy mode, `send` leaves copy mode once before typing. Generic tmux cannot preserve copy mode while typing into the pane process behind it.
- The clear-line key (`C-u`) reliably clears typed shell input. In a full-screen program or an editor with custom key bindings it is best effort. The saved message in the inbox is the fallback.
- If the target pane is dead, `send` stops before saving and exits nonzero.
- If a phase fails after the save, `send` prints the message ID, exits nonzero with the failed phase on stderr, and keeps the message in the inbox. It withholds `Enter` when the state check before it fails, and never sends a later retry. A failure after the paste means the command may remain unsubmitted in the target prompt and `Enter` was withheld. The recipient can find the message with `tmux-agent inbox`.
- Exit 0 means tmux accepted all three input events (the lone `C-u`, the bracketed-paste event, and the `Enter`). tmux cannot confirm that Cursor rendered or submitted the input: Cursor's input editor is not visible to `tmux capture-pane` even while the user sees the text, so no capture-based confirmation is attempted. The explicit bracketed paste and short pauses work around Cursor's input-event bugs, and the state checks reduce, but cannot remove, races with the user typing in the same pane. The durable inbox is the fallback.

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
