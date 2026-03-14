#!/usr/bin/env bash
# PreToolUse hook: block Bash commands that reference sensitive directories.
# Exit 0 = allow, exit 2 = block.

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
    echo "BLOCKED: '$COMMAND' accesses sensitive path '$dir'." >&2
    exit 2
  fi
done

exit 0
