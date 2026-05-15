#!/usr/bin/env bash
# Claude Code Notification hook.
#
# Writes one JSON file to the host's wst notify queue
# ($HOME/.cache/wst/notify-queue). A host-side systemd user service
# (wst-notify-dispatcher) watches the queue and dispatches each entry via
# notify-send + tmux pane focus + wmctrl.
#
# The queue indirection lets this hook work both from host Claude Code and
# from Claude Code running inside a wst stream's devcontainer (where direct
# access to DBus / the host tmux socket / X11 isn't plumbed). The queue dir
# is bind-mounted into stream containers by wst-container-up.

set -euo pipefail

INPUT=$(cat)

CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty')

# Session id = transcript filename without .jsonl. Used downstream by the
# dispatcher to dedupe notifications per Claude session.
SESSION_ID=""
if [[ -n "$TRANSCRIPT" ]]; then
  SESSION_ID=$(basename "$TRANSCRIPT" .jsonl)
fi

# --- Project name ---
PROJECT=""
[[ -n "$CWD" ]] && PROJECT=$(basename "$CWD")
PROJECT="${PROJECT:-Claude Code}"

# --- Git / stream context ---
GIT_INFO=""
if [[ -n "$CWD" ]] && command -v git >/dev/null 2>&1; then
  BRANCH=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
  if [[ -n "$BRANCH" ]]; then
    SLUG=$(basename "$CWD")
    PARENT=$(dirname "$CWD")
    if [[ -n "${WST_STREAM:-}" ]]; then
      GIT_INFO="stream: $BRANCH"
    elif [[ "$PARENT" == "$HOME/Projects/"* && "$SLUG" != "main" && -d "$CWD/.git" ]]; then
      GIT_INFO="stream: $BRANCH"
    else
      GIT_INFO="branch: $BRANCH"
    fi
  fi
fi

# --- Transcript summary (last assistant text, 200 chars) ---
SUMMARY=""
if [[ -n "$TRANSCRIPT" && -f "$TRANSCRIPT" ]]; then
  SUMMARY=$(tail -n 20 "$TRANSCRIPT" 2>/dev/null \
    | jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text' 2>/dev/null \
    | tail -n 1 \
    | head -c 200 \
    || true)
fi

# --- Compose ---
TITLE="Claude Code — $PROJECT"
BODY=""
[[ -n "$GIT_INFO" ]] && BODY+="$GIT_INFO"
if [[ -n "$SUMMARY" ]]; then
  [[ -n "$BODY" ]] && BODY+=$'\n'
  BODY+="$SUMMARY"
fi
BODY="${BODY:-Waiting for your input}"

# --- Tmux pane target (host-only; container PID namespace can't walk to host
#     tmux pane_pid, so we skip the walk and let the dispatcher resolve via
#     WST_PROJECT/WST_STREAM env). ---
PANE_TARGET=""
if [[ -z "${WST_STREAM:-}" ]] && command -v tmux >/dev/null 2>&1 \
     && tmux list-panes -a >/dev/null 2>&1; then
  PANE_LIST=$(tmux list-panes -a -F "#{pane_pid} #{session_name}:#{window_index}.#{pane_index}")
  PID=$$
  while [[ -n "$PID" && "$PID" != "1" ]]; do
    MATCH=$(echo "$PANE_LIST" | awk -v pid="$PID" '$1 == pid { print $2; exit }')
    if [[ -n "$MATCH" ]]; then
      PANE_TARGET="$MATCH"
      break
    fi
    PID=$(ps -o ppid= -p "$PID" 2>/dev/null | tr -d ' ') || break
  done
fi

# --- Write JSON to queue ---
queue_dir="$HOME/.cache/wst/notify-queue"
mkdir -p "$queue_dir"
tmp="$queue_dir/.$(date +%s%N)-$$.json.tmp"
final="$queue_dir/$(date +%s%N)-$$.json"
jq -n \
  --arg title "$TITLE" \
  --arg body "$BODY" \
  --arg pane_target "$PANE_TARGET" \
  --arg wst_project "${WST_PROJECT:-}" \
  --arg wst_stream "${WST_STREAM:-}" \
  --arg session_id "$SESSION_ID" \
  '{
    title: $title,
    body: $body,
    pane_target: (if $pane_target == "" then null else $pane_target end),
    wst_project:  (if $wst_project  == "" then null else $wst_project  end),
    wst_stream:   (if $wst_stream   == "" then null else $wst_stream   end),
    session_id:   (if $session_id   == "" then null else $session_id   end)
  }' > "$tmp"
mv "$tmp" "$final"
