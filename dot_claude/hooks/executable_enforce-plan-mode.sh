#!/usr/bin/env bash
# PreToolUse hook for Edit / Write / NotebookEdit:
# In plan mode, deny any write target outside ~/.claude/plans/*.md.
# Defense in depth — the harness already enforces plan mode, but a regression
# (or a hook returning "allow") could open a hole. This hook closes it.

set -euo pipefail

INPUT=$(cat)
MODE=$(printf '%s' "$INPUT" | jq -r '.permission_mode // empty')

if [[ "$MODE" != "plan" ]]; then
  exit 0
fi

TARGET=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.notebook_path // empty')

# Allow writes only to the harness-allocated plan file.
if [[ "$TARGET" == "$HOME/.claude/plans/"*.md ]]; then
  exit 0
fi

jq -n --arg p "$TARGET" '{
  hookSpecificOutput: {
    hookEventName: "PreToolUse",
    permissionDecision: "deny",
    permissionDecisionReason: ("Plan mode: refusing write to " + $p + ". Only ~/.claude/plans/*.md is writable in plan mode; finalize the plan and call ExitPlanMode.")
  }
}'
exit 0
