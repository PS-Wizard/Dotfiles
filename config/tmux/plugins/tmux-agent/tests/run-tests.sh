#!/usr/bin/env bash
# tmux-agent regression tests.
# Every test runs on its own isolated tmux server (private socket under
# $TMP); all servers are killed on exit. Never touches any other server.
set -u

HERE=$(cd "$(dirname "$0")" && pwd)
AGENT=$HERE/../bin/tmux-agent
TMUX_BIN=$(command -v tmux)
UID_=$(id -u)
TMP=$(mktemp -d /tmp/tmux-agent-test.XXXXXX)
PASSED=0 FAILED=0

cleanup() {
  local s pid
  for s in "$TMP"/*.sock; do
    [[ -S $s ]] || continue
    pid=$("$TMUX_BIN" -S "$s" display-message -p '#{pid}' 2>/dev/null)
    "$TMUX_BIN" -S "$s" kill-server 2>/dev/null
    [[ -n ${pid:-} ]] && rm -rf "/tmp/tmux-agent-$UID_/server-$pid"
  done
  rm -rf "$TMP"
}
trap cleanup EXIT

tm() { local sock=$1; shift; "$TMUX_BIN" -S "$sock" -f /dev/null "$@"; }
# Strip inherited TMUX/TMUX_PANE: the agent must act on the explicit
# --socket, never on the caller's interactive tmux session.
agent() { local sock=$1; shift; env -u TMUX -u TMUX_PANE "$AGENT" --socket "$sock" "$@"; }
agent_pane() { local sock=$1 pane=$2; shift 2; env -u TMUX -u TMUX_PANE "$AGENT" --socket "$sock" --pane "$pane" "$@"; }

mk_tracelog() { # bin_dir logfile -> tmux wrapper that records key/subcommand calls
  local bin=$1 log=$2
  mkdir -p "$bin"
  cat > "$bin/tmux" <<EOF
#!/bin/sh
for a in "\$@"; do
  case \$a in
    send-keys|capture-pane|display-message) printf '%s\n' "\$*" >> '$log'; break ;;
  esac
done
exec '$TMUX_BIN' "\$@"
EOF
  chmod +x "$bin/tmux"
}

new_server() { # name -> socket path
  printf '%s' "$TMP/$1.sock"
}

mk_reader() { # sock session logfile -> pane id; pane logs every input line
  local sock=$1 sess=$2 log=$3
  # Emulate a terminal-aware app: strip the bracketed-paste framing
  # (ESC[200~ / ESC[201~) so the log holds the command Cursor would receive.
  cat > "$TMP/reader-$sess.sh" <<EOF
#!/usr/bin/env bash
while IFS= read -r l; do
  l=\${l//\$'\033[200~'/}
  l=\${l//\$'\033[201~'/}
  printf '%s\n' "\$l" >> '$log'
done
EOF
  tm "$sock" new-session -d -s "$sess" "bash $TMP/reader-$sess.sh"
  tm "$sock" display-message -p -t "$sess:0.0" '#{pane_id}'
}

await_log() { # logfile pattern [timeout s]
  local file=$1 pat=$2 deadline=$(( SECONDS + ${3:-5} ))
  while (( SECONDS <= deadline )); do
    [[ -f $file ]] && grep -q -- "$pat" "$file" && return 0
    sleep 0.05
  done
  return 1
}

poll_pane() { # sock pane format want [timeout s]
  local sock=$1 pane=$2 fmt=$3 want=$4 deadline=$(( SECONDS + ${5:-5} )) v
  while (( SECONDS <= deadline )); do
    v=$(tm "$sock" display-message -p -t "$pane" "$fmt" 2>/dev/null) || { sleep 0.05; continue; }
    [[ $v == "$want" ]] && return 0
    sleep 0.05
  done
  return 1
}

t_cross_session() {
  local sock log pane id
  sock=$(new_server cross); log=$TMP/cross.log
  tm "$sock" new-session -d -s src 'sleep 30'
  pane=$(mk_reader "$sock" dst "$log")
  agent_pane "$sock" "$pane" mark target >/dev/null || return 1
  id=$(agent "$sock" send target 'hello world') || return 1
  await_log "$log" "tmux-agent read $id" || return 1
  agent_pane "$sock" "$pane" read "$id" | grep -q 'hello world' || return 1
  [[ $(agent_pane "$sock" "$pane" inbox) == "$id" ]] || return 1
  agent_pane "$sock" "$pane" ack "$id" || return 1
  [[ -z $(agent_pane "$sock" "$pane" inbox) ]] || return 1
}

t_marker_survives_pane_move() {
  local sock log pane id
  sock=$(new_server move); log=$TMP/move.log
  pane=$(mk_reader "$sock" a "$log")
  agent_pane "$sock" "$pane" mark mover >/dev/null || return 1
  tm "$sock" new-session -d -s b 'sleep 30'
  tm "$sock" new-window -t b || return 1
  tm "$sock" move-pane -s "$pane" -t b:1.0 || return 1
  [[ $(tm "$sock" show-options -p -v -t "$pane" @agent_marker) == mover ]] || return 1
  id=$(agent "$sock" send mover 'after move') || return 1
  await_log "$log" "tmux-agent read $id" || return 1
}

t_concurrent_sends() {
  local sock log pane n=4 i out rc line id
  sock=$(new_server conc); log=$TMP/conc.log
  pane=$(mk_reader "$sock" c "$log")
  agent_pane "$sock" "$pane" mark target >/dev/null || return 1
  local pids=() ids=()
  for i in $(seq 1 "$n"); do
    agent "$sock" send target "msg$i" > "$TMP/c$i.out" 2> "$TMP/c$i.err" &
    pids+=("$!")
  done
  # Wait for every sender even if one fails; combine statuses afterward.
  rc=0
  for i in $(seq 1 "$n"); do
    wait "${pids[$((i - 1))]}" || rc=1
  done
  [[ $rc == 0 ]] || { cat "$TMP"/c*.err >&2; return 1; }
  for i in $(seq 1 "$n"); do
    out=$(<"$TMP/c$i.out")
    [[ $out =~ ^m[0-9]+-[0-9]+-[0-9]+$ ]] || return 1
    ids+=("$out")
  done
  # The per-pane lock groups each send's C-u, text, and Enter so the pane only
  # ever sees one exact complete command line per ID. No merged lines, no blank
  # lines: a blank line would mean a stray lone Enter reached the pane.
  [[ $(wc -l < "$log") == "$n" ]] || return 1
  while IFS= read -r line; do
    [[ $line =~ ^tmux-agent\ read\ m[0-9]+-[0-9]+-[0-9]+$ ]] || return 1
  done < "$log"
  for id in "${ids[@]}"; do
    [[ $(grep -cx "tmux-agent read $id" "$log") == 1 ]] || return 1
  done
}

t_partial_prompt_input() {
  local sock log pane id
  sock=$(new_server prompt); log=$TMP/prompt.log
  pane=$(mk_reader "$sock" p "$log")
  agent_pane "$sock" "$pane" mark self >/dev/null || return 1
  tm "$sock" send-keys -t "$pane" -l 'leftover text '
  # send-keys writes straight to the pty, so the partial line is already
  # buffered; a short pause keeps the ordering deterministic without capture.
  sleep 0.2
  id=$(agent_pane "$sock" "$pane" send self 'ping') || return 1
  await_log "$log" "tmux-agent read $id" || return 1
  # The line must be exactly the command: the lone C-u killed the leftover text.
  [[ $(wc -l < "$log") == 1 ]] || return 1
  grep -qx "tmux-agent read $id" "$log" || return 1
}

t_copy_mode() {
  local sock log pane id
  sock=$(new_server copy); log=$TMP/copy.log
  pane=$(mk_reader "$sock" cm "$log")
  agent_pane "$sock" "$pane" mark target >/dev/null || return 1
  tm "$sock" copy-mode -t "$pane" || return 1
  poll_pane "$sock" "$pane" '#{pane_mode}' copy-mode || return 1
  id=$(agent "$sock" send target 'while copying') || return 1
  await_log "$log" "tmux-agent read $id" || return 1
  # Copy mode was left once before typing; no mode afterwards.
  poll_pane "$sock" "$pane" '#{pane_mode}' '' || return 1
  [[ $(wc -l < "$log") == 1 ]] || return 1
  grep -qx "tmux-agent read $id" "$log" || return 1
}

t_three_ordered_sends() {
  local sock log pane id trace seq
  sock=$(new_server three); log=$TMP/three.log; trace=$TMP/three.trace
  pane=$(mk_reader "$sock" three "$log")
  agent_pane "$sock" "$pane" mark target >/dev/null || return 1
  mk_tracelog "$TMP/threebin" "$trace"
  id=$(PATH="$TMP/threebin:$PATH" agent "$sock" send target 'ordered') || return 1
  await_log "$log" "tmux-agent read $id" || return 1
  # No capture-pane dependency and no End wake event anywhere.
  ! grep -q 'capture-pane' "$trace" || return 1
  ! grep -qE ' End$' "$trace" || return 1
  # Exactly three send-keys events, each phase alone: C-u only, one literal
  # bracketed-paste event only, Enter only. A combined query runs before the
  # paste and before Enter.
  seq=$(awk '
    /send-keys/ {
      if ($0 ~ /-- C-u$/) print "clear";
      else if ($0 ~ /-l -- / && $0 ~ /200~tmux-agent read /) print "text";
      else if ($0 ~ /-- Enter$/) print "enter";
      next
    }
    /pane_dead/ {
      if (index($0, "pane_dead}|#{pane_mode}")) print "state";
    }
  ' "$trace")
  [[ $seq == $'clear\nstate\ntext\nstate\nenter' ]] || return 1
  # The middle event is exactly one literal bracketed-paste sequence framing
  # only the read command: ESC[200~ + command + ESC[201~, never the body.
  want="-S $sock send-keys -t $pane -l -- "$'\033[200~'"tmux-agent read $id"$'\033[201~'
  grep -qxF -- "$want" "$trace" || return 1
  ! grep -q 'ordered' "$trace" || return 1
  # The reader saw exactly the submitted command, no blank extra line.
  [[ $(wc -l < "$log") == 1 ]] || return 1
  grep -qx "tmux-agent read $id" "$log" || return 1
}

t_state_recheck_withholds_enter() {
  local sock log pane out rc id
  sock=$(new_server withhold); log=$TMP/withhold.log
  pane=$(mk_reader "$sock" w "$log")
  agent_pane "$sock" "$pane" mark target >/dev/null || return 1
  mkdir -p "$TMP/wbin"
  echo 0 > "$TMP/withhold.statecount"
  # Fake tmux wrapper: log send-keys, pass everything through, except the
  # second state check (before Enter), which reports a copy-mode. The text
  # phase has already run, so Enter must be withheld.
  cat > "$TMP/wbin/tmux" <<EOF
#!/bin/sh
for a in "\$@"; do
  if [ "\$a" = send-keys ]; then printf '%s\n' "\$*" >> '$TMP/withhold.sendlog'; break; fi
done
prev=
for a in "\$@"; do
  case \$a in
    '#{pane_id}|#{pane_dead}|#{pane_mode}')
      n=\$(cat '$TMP/withhold.statecount' 2>/dev/null || echo 0)
      n=\$((n+1)); echo "\$n" > '$TMP/withhold.statecount'
      if [ "\$n" -ge 2 ]; then printf '%s|0|copy-mode\n' "\$prev"; exit 0; fi
      ;;
  esac
  prev=\$a
done
exec '$TMUX_BIN' "\$@"
EOF
  chmod +x "$TMP/wbin/tmux"
  out=$(PATH="$TMP/wbin:$PATH" agent "$sock" send target 'withheld' 2> "$TMP/withhold.err"); rc=$?
  [[ $rc != 0 ]] || return 1
  [[ $out =~ ^m[0-9]+-[0-9]+-[0-9]+$ ]] || return 1
  id=$out
  grep -q 'phase 2 (paste command) failed' "$TMP/withhold.err" || return 1
  grep -q 'Enter was withheld' "$TMP/withhold.err" || return 1
  grep -q 'stays pending' "$TMP/withhold.err" || return 1
  # Durable.
  agent_pane "$sock" "$pane" read "$id" | grep -q 'withheld' || return 1
  # C-u and the bracketed-paste event were sent; Enter and any End were withheld.
  [[ $(wc -l < "$TMP/withhold.sendlog") == 2 ]] || return 1
  grep -qE ' -- C-u$' "$TMP/withhold.sendlog" || return 1
  want="-S $sock send-keys -t $pane -l -- "$'\033[200~'"tmux-agent read $id"$'\033[201~'
  grep -qxF -- "$want" "$TMP/withhold.sendlog" || return 1
  ! grep -qE ' -- Enter$' "$TMP/withhold.sendlog" || return 1
  ! grep -qE ' End$' "$TMP/withhold.sendlog" || return 1
}

t_dead_pane() {
  local sock pane pid state out rc
  sock=$(new_server dead)
  tm "$sock" new-session -d -s d 'sleep 30'
  pane=$(tm "$sock" display-message -p -t d:0.0 '#{pane_id}')
  tm "$sock" set-option -t d remain-on-exit on
  tm "$sock" respawn-pane -k -t "$pane" 'true'
  poll_pane "$sock" "$pane" '#{pane_dead}' 1 || return 1
  agent_pane "$sock" "$pane" mark gone >/dev/null || return 1
  out=$(agent "$sock" send gone 'should fail' 2> "$TMP/dead.err"); rc=$?
  [[ $rc != 0 ]] || return 1
  [[ -z $out ]] || return 1
  grep -qE 'dead|no live pane' "$TMP/dead.err" || return 1
  pid=$(tm "$sock" display-message -p '#{pid}')
  state="/tmp/tmux-agent-$UID_/server-$pid"
  ! compgen -G "$state/pane-${pane#%}/msg-*" >/dev/null || return 1
}

t_durable_on_notify_failure() {
  local sock log pane id rc out
  sock=$(new_server notify); log=$TMP/notify.log
  pane=$(mk_reader "$sock" n "$log")
  agent_pane "$sock" "$pane" mark target >/dev/null || return 1
  # Fake tmux wrapper: everything passes through, send-keys always fails.
  mkdir -p "$TMP/fakebin"
  {
    echo '#!/bin/sh'
    echo 'for a in "$@"; do'
    echo '  [ "$a" = send-keys ] && exit 1'
    echo 'done'
    echo "exec '$TMUX_BIN' \"\$@\""
  } > "$TMP/fakebin/tmux"
  chmod +x "$TMP/fakebin/tmux"
  out=$(PATH="$TMP/fakebin:$PATH" agent "$sock" send target 'durable' 2> "$TMP/notify.err"); rc=$?
  [[ $rc != 0 ]] || return 1
  grep -q 'phase 1 (clear prompt) failed' "$TMP/notify.err" || return 1
  grep -q 'stays pending' "$TMP/notify.err" || return 1
  [[ $out =~ ^m[0-9]+-[0-9]+-[0-9]+$ ]] || return 1
  id=$out
  agent_pane "$sock" "$pane" read "$id" | grep -q 'durable' || return 1
}

for t in t_cross_session t_marker_survives_pane_move t_concurrent_sends \
         t_partial_prompt_input t_copy_mode t_three_ordered_sends \
         t_state_recheck_withholds_enter t_dead_pane \
         t_durable_on_notify_failure; do
  if "$t"; then
    echo "ok - $t"; PASSED=$((PASSED + 1))
  else
    echo "not ok - $t"; FAILED=$((FAILED + 1))
  fi
done
echo "$PASSED passed, $FAILED failed"
[[ $FAILED == 0 ]]
