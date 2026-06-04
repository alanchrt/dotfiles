# Claude Code Instructions

Read and follow the shared agent instructions in `~/.codex/AGENTS.md`.

Claude-specific mechanics:

- For non-trivial implementation work, start in Claude plan mode and produce a plan before writing code.
- In plan mode, the only writable target is the harness-allocated plan file at `~/.claude/plans/<slug>.md`. Do not Edit/Write/NotebookEdit anywhere else, and do not run Bash commands that mutate state. If a real change is needed to validate the plan, ask via `AskUserQuestion`. Plan mode ends only via `ExitPlanMode`.
- When revising an already-presented plan in response to feedback, apply the change as the smallest possible **targeted `Edit` calls** to the plan file — never rewrite it wholesale — so the CLI's word-level diff shows exactly what changed. Then call `ExitPlanMode` with the plan body prefixed by a `## Changed in this revision` section listing only the edits as terse bullets (what changed and why), with the full plan below it. The goal is that I can verify the change from the changelog and inline diff without re-reading the whole plan.
- If `.claude/rules/graphite.md` exists, its content is sourced from the same shared Graphite rule used by `AGENTS.override.md`. Follow it; the PreToolUse hook may block raw `git`/`gh` commands with Graphite equivalents.
