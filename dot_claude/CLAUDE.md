# Claude Code Instructions

Read and follow the shared agent instructions in `~/.codex/AGENTS.md`.

Claude-specific mechanics:

- For non-trivial implementation work, start in Claude plan mode and produce a plan before writing code.
- In plan mode, the only writable target is the harness-allocated plan file at `~/.claude/plans/<slug>.md`. Do not Edit/Write/NotebookEdit anywhere else, and do not run Bash commands that mutate state. If a real change is needed to validate the plan, ask via `AskUserQuestion`. Plan mode ends only via `ExitPlanMode`.
- If `.claude/rules/graphite.md` exists, its content is sourced from the same shared Graphite rule used by `AGENTS.override.md`. Follow it; the PreToolUse hook may block raw `git`/`gh` commands with Graphite equivalents.
