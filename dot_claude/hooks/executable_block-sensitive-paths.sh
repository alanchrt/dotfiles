#!/usr/bin/env bash
# PreToolUse hook: prompt before Bash commands that reference sensitive directories.
# Exit 0 = allow, JSON ask = prompt.

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [[ -z "$COMMAND" ]]; then
  exit 0
fi

SENSITIVE_DIRS=(
  "$HOME/.ssh"
  "$HOME/.gnupg"
  "$HOME/.gpg"
  "$HOME/.aws"
  "$HOME/.config/gcloud"
  "$HOME/.kube"
  "$HOME/.mozilla"
  "$HOME/.config/google-chrome"
  "$HOME/.config/chromium"
  "$HOME/.config/BraveSoftware"
)

for dir in "${SENSITIVE_DIRS[@]}"; do
  if echo "$COMMAND" | grep -qF "$dir"; then
    jq -n --arg reason "'$COMMAND' accesses sensitive path '$dir'." '{
      hookSpecificOutput: {
        hookEventName: "PreToolUse",
        permissionDecision: "ask",
        permissionDecisionReason: $reason
      }
    }'
    exit 0
  fi
done

jq -n '{hookSpecificOutput: {hookEventName: "PreToolUse", permissionDecision: "allow"}}'
exit 0
