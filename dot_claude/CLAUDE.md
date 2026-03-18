# Workflow

- Always draft a plan before starting implementation work.
- Once you begin working, be independent until finished. Do not ask unnecessary questions mid-task.
- Make small, focused commits as you work unless explicitly told not to commit.
- Before committing, make a small effort to verify changes work when reasonable (e.g., run a linter, execute a relevant command, check syntax). Don't skip this just to move faster.
- Before committing to the main/master branch, always ask for confirmation first. (This does not apply when working in a worktree on a feature branch.)
- When finished, summarize what was done so the work can be reviewed in a pull request.

# Worktree Workflow

During planning, assess whether the task warrants its own branch and worktree.

**Use a worktree when:**
- On `main`/`master` and the task is more than a trivial change
- The task is unrelated to the current branch's purpose (branches should stay on-topic — this applies whether the branch has uncommitted work or not)
- The task would benefit from an isolated PR

**Don't use a worktree when:**
- Small, quick fixes (typos, single-line changes)
- Already on a feature branch for this task
- The user explicitly says to work on the current branch

- Use `EnterWorktree` with a descriptive kebab-case name (e.g., `fix-auth-timeout`, `add-search-api`)
- Commit freely on the worktree branch (no main-branch confirmation needed)
- On completion, keep the worktree (`ExitWorktree` with `action: "keep"`) and report the branch name

# Production Safety

The following commands interact with production systems: heroku, railway, gcloud, gh, terraform, kubectl, k9s, ssh.

- You may use these tools for read-only operations (viewing logs, listing resources, checking status).
- Never run commands that could modify production state without explicit confirmation.
- If you are unsure whether a command is read-only, ask first.

# Git Safety

- Avoid destructive git commands (reset --hard, clean -f, stash drop/clear, push --force, branch -D, checkout -- .).
- If a destructive git command is truly necessary, explain why and ask for confirmation first.
- Prefer safe alternatives: create a backup branch before resetting, use git stash instead of discarding changes.
