#!/usr/bin/env bash
# Notification hook: send a context-rich desktop notification showing
# project name, branch/worktree info, and a summary of what Claude is
# working on or asking about.

set -euo pipefail

INPUT=$(cat)

CWD=$(echo "$INPUT" | jq -r '.cwd // empty')
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // empty')

# --- Project name ---
PROJECT=""
if [[ -n "$CWD" ]]; then
  PROJECT=$(basename "$CWD")
fi
PROJECT="${PROJECT:-Claude Code}"

# --- Git context ---
GIT_INFO=""
if [[ -n "$CWD" ]] && command -v git >/dev/null 2>&1; then
  BRANCH=$(git -C "$CWD" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
  if [[ -n "$BRANCH" ]]; then
    GIT_DIR=$(git -C "$CWD" rev-parse --git-dir 2>/dev/null || true)
    GIT_COMMON=$(git -C "$CWD" rev-parse --git-common-dir 2>/dev/null || true)
    if [[ -n "$GIT_DIR" && -n "$GIT_COMMON" && "$GIT_DIR" != "$GIT_COMMON" ]]; then
      GIT_INFO="worktree: $BRANCH"
    else
      GIT_INFO="branch: $BRANCH"
    fi
  fi
fi

# --- Transcript summary ---
SUMMARY=""
if [[ -n "$TRANSCRIPT" && -f "$TRANSCRIPT" ]]; then
  # Read the last few lines looking for the most recent assistant message
  SUMMARY=$(tail -n 20 "$TRANSCRIPT" 2>/dev/null \
    | jq -r 'select(.type == "assistant") | .message.content[]? | select(.type == "text") | .text' 2>/dev/null \
    | tail -n 1 \
    | head -c 200 \
    || true)
fi

# --- Compose notification ---
TITLE="Claude Code — $PROJECT"

BODY=""
if [[ -n "$GIT_INFO" ]]; then
  BODY="$GIT_INFO"
fi
if [[ -n "$SUMMARY" ]]; then
  [[ -n "$BODY" ]] && BODY="$BODY\n"
  BODY="$BODY$SUMMARY"
fi
BODY="${BODY:-Waiting for your input}"

# --- Find tmux pane (if running inside tmux) ---
TMUX_TARGET=""
if command -v tmux >/dev/null 2>&1 && tmux list-panes -a >/dev/null 2>&1; then
  # Walk up the process tree from $$ to find a PID that matches a tmux pane
  PANE_LIST=$(tmux list-panes -a -F "#{pane_pid} #{session_name}:#{window_index}.#{pane_index}")
  PID=$$
  while [[ -n "$PID" && "$PID" != "1" ]]; do
    MATCH=$(echo "$PANE_LIST" | awk -v pid="$PID" '$1 == pid { print $2; exit }')
    if [[ -n "$MATCH" ]]; then
      TMUX_TARGET="$MATCH"
      break
    fi
    PID=$(ps -o ppid= -p "$PID" 2>/dev/null | tr -d ' ') || break
  done
fi

BODY_RENDERED=$(printf '%b' "$BODY")

if [[ -n "$TMUX_TARGET" ]]; then
  # Extract session:window for select-window
  TMUX_WINDOW="${TMUX_TARGET%.*}"

  # Clickable notification — runs in a detached background subshell
  (
    ACTION=$(notify-send -i dialog-information -A "default=Focus" "$TITLE" "$BODY_RENDERED" 2>/dev/null || true)
    if [[ "$ACTION" == "default" ]]; then
      tmux select-window -t "$TMUX_WINDOW" 2>/dev/null || true
      tmux select-pane -t "$TMUX_TARGET" 2>/dev/null || true
    fi
  ) &>/dev/null &
  disown
else
  # Fallback: plain notification (no tmux or pane not found)
  notify-send -i dialog-information "$TITLE" "$BODY_RENDERED"
fi
