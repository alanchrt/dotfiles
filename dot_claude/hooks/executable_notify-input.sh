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

notify-send -i dialog-information "$TITLE" "$(printf '%b' "$BODY")"
