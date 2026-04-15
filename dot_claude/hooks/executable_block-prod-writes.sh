#!/usr/bin/env python3
# PreToolUse hook: prompt before production-modifying commands unless they
# match known read-only subcommand patterns.

import json
import os
import re
import shlex
import sys


def positional_args(tokens):
    """Return positional args, skipping flags and their space-separated values."""
    result = []
    i = 0
    while i < len(tokens):
        t = tokens[i]
        if t.startswith("-"):
            if "=" not in t:
                i += 2  # --flag value: skip both
            else:
                i += 1  # --flag=value: skip one
        else:
            result.append(t)
            i += 1
    return result


PRODUCTION_TOOLS = {"heroku", "railway", "vercel", "gcloud", "gh",
                    "terraform", "kubectl", "az", "k9s", "ssh", "git", "gt"}


def is_readonly(cmd):
    try:
        tokens = shlex.split(cmd)
    except ValueError:
        # Malformed quoting (e.g. heredoc in a multi-line command).
        # Fall back to simple split to identify the binary; allow if it's
        # not a known production tool.
        raw = cmd.split()
        while raw and re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", raw[0]):
            raw.pop(0)
        binary = os.path.basename(raw[0]) if raw else ""
        return binary not in PRODUCTION_TOOLS

    if not tokens:
        return True

    # Strip leading KEY=VALUE env assignments
    while tokens and re.match(r"^[A-Za-z_][A-Za-z0-9_]*=", tokens[0]):
        tokens.pop(0)

    if not tokens:
        return True

    binary = os.path.basename(tokens[0])
    args = positional_args(tokens[1:])
    sub = args[0] if len(args) > 0 else ""
    sub2 = args[1] if len(args) > 1 else ""

    if binary == "heroku":
        return sub in {"logs", "ps", "config", "info", "status", "apps", "addons:info", "pg:info"}

    if binary == "railway":
        return sub in {"logs", "status", "list", "whoami"}

    if binary == "vercel":
        return sub in {"list", "ls", "inspect", "logs", "whoami", "project", "env", "dns", "certs", "domains"}

    if binary == "gcloud":
        return bool(re.search(r"\b(list|describe|get-iam-policy|info)\b", cmd))

    if binary == "gh":
        if sub == "pr":
            return sub2 in {"list", "view", "status", "checks", "diff", "create"}
        if sub == "issue":
            return sub2 in {"list", "view", "status"}
        if sub == "repo":
            return sub2 == "view"
        if sub == "api":
            # Allow GET requests (no -X flag, or explicit -X GET)
            return not re.search(r"-X\s+(?!GET)", cmd)
        if sub == "run":
            return sub2 in {"list", "view"}
        return False

    if binary == "terraform":
        if sub in {"plan", "show", "output", "validate", "fmt", "providers"}:
            return True
        if sub == "state":
            return sub2 in {"list", "show"}
        return False

    if binary == "kubectl":
        if sub in {"get", "describe", "logs", "top", "explain", "api-resources",
                   "api-versions", "cluster-info", "version"}:
            return True
        if sub == "config":
            return sub2 in {"view", "current-context"}
        return False

    if binary == "git":
        raw = tokens[1:]
        if sub == "reset" and "--hard" in raw:
            return False
        if sub == "push" and {"--force", "-f", "--force-with-lease"} & set(raw):
            return False
        if sub == "clean" and any(
            t == "--force" or (t.startswith("-") and not t.startswith("--") and "f" in t)
            for t in raw
        ):
            return False
        if sub == "checkout" and "--" in raw:
            return False
        if sub == "restore":
            return False
        if sub == "stash" and sub2 in {"drop", "clear"}:
            return False
        if sub == "branch" and ("-D" in raw or ("--delete" in raw and "--force" in raw)):
            return False
        return True

    if binary == "gt":
        if sub in {"log", "ls", "status", "up", "down", "trunk", "branch", "info"}:
            return True
        if sub in {"create", "modify", "restack", "sync"}:
            return True
        if sub == "submit":
            return "--force" not in raw
        if sub == "repo":
            return sub2 != "init" or "--force" not in raw
        return False

    if binary == "az":
        return bool(re.search(r"\b(list|show|get)\b", cmd))

    if binary in {"k9s", "ssh"}:
        return False  # Always block — interactive TUI / interactive shell

    # Not a production command, allow
    return True


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    command = data.get("tool_input", {}).get("command", "")

    if not command:
        sys.exit(0)

    # Join multi-line commands into one line before splitting on &&/;
    # This prevents multi-line -m values from being split mid-quote
    single_line = " ".join(command.splitlines())

    # Split on && and ; to check each command in a chain
    all_readonly = True
    for part in re.split(r"\s*&&\s*|\s*;\s*", single_line):
        part = part.strip()
        if not part:
            continue
        if not is_readonly(part):
            all_readonly = False
            break

    if all_readonly:
        result = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "allow",
            }
        }
    else:
        result = {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "ask",
                "permissionDecisionReason": f"'{command}' may modify production state.",
            }
        }

    print(json.dumps(result))
    sys.exit(0)


if __name__ == "__main__":
    main()
