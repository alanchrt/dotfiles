#!/usr/bin/env python3
# PreToolUse hook: in Graphite-enabled projects (those with
# .claude/rules/graphite.md), deny git/gh commands that have a documented
# `gt` equivalent. The reason string names the correct verb so Claude can
# self-correct without prompting the user.

import json
import os
import re
import shlex
import sys
from pathlib import Path


def graphite_enabled(start):
    """True if .claude/rules/graphite.md exists at or above start."""
    try:
        p = Path(start).resolve()
    except (OSError, RuntimeError, ValueError):
        return False
    for d in (p, *p.parents):
        if (d / ".claude" / "rules" / "graphite.md").exists():
            return True
    return False


REBASE_RECOVERY = {
    "--continue", "--abort", "--skip", "--quit",
    "--edit-todo", "--show-current-patch",
}


def check_segment(cmd):
    """Return (suggested_gt_verb, detail) if blocked, else None."""
    try:
        tokens = shlex.split(cmd)
    except ValueError:
        return None
    while tokens and re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", tokens[0]):
        tokens.pop(0)
    if not tokens:
        return None

    binary = os.path.basename(tokens[0])
    rest = tokens[1:]

    # `gt` is always allowed. Graphite intentionally rewrites history
    # (`gt modify`, `gt restack`, `gt absorb`, `gt squash`) — this hook must
    # never stand in its way. Only raw `git`/`gh` invocations are gated.
    if binary == "gt":
        return None

    if binary == "git":
        if not rest:
            return None
        sub = rest[0]
        if sub == "commit":
            if "--amend" in rest:
                return ("gt modify", "`git commit --amend`")
            return ("gt create -m \"...\"", "`git commit`")
        if sub == "rebase":
            if any(t in REBASE_RECOVERY for t in rest):
                return None
            return ("gt restack", "`git rebase`")
        if sub == "checkout" and "-b" in rest:
            return ("gt create <name>", "`git checkout -b`")
        if sub == "switch" and ("-c" in rest or "-C" in rest):
            return ("gt create <name>", "`git switch -c`")
        return None

    if binary == "gh":
        if len(rest) >= 2 and rest[0] == "pr" and rest[1] == "create":
            return ("gt submit", "`gh pr create`")
        return None

    return None


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    if not isinstance(data, dict) or data.get("tool_name") != "Bash":
        sys.exit(0)

    tool_input = data.get("tool_input") or {}
    if not isinstance(tool_input, dict):
        sys.exit(0)
    command = tool_input.get("command") or ""
    if not command:
        sys.exit(0)

    cwd = data.get("cwd") or os.getcwd()
    if not graphite_enabled(cwd):
        sys.exit(0)

    single_line = " ".join(command.splitlines())
    for part in re.split(r"\s*&&\s*|\s*;\s*", single_line):
        part = part.strip()
        if not part:
            continue
        result = check_segment(part)
        if not result:
            continue
        gt_verb, what = result
        reason = (
            f"{what} is blocked: this project uses Graphite "
            f"(`.claude/rules/graphite.md` is present). "
            f"Use `{gt_verb}` instead. "
            f"See `.claude/rules/graphite.md` for the full verb mapping."
        )
        print(json.dumps({
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": reason,
            }
        }))
        sys.exit(0)

    sys.exit(0)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        # Fail open (exit 0) on any unexpected error so a hook bug never
        # blocks the user's tool call. Print a one-line stderr summary
        # instead of letting a multi-line traceback spam the UI.
        print(f"enforce-graphite hook error: {type(e).__name__}: {e}", file=sys.stderr)
        sys.exit(0)
