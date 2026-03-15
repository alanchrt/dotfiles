# Workflow

- Always draft a plan before starting implementation work.
- Once you begin working, be independent until finished. Do not ask unnecessary questions mid-task.
- Make small, focused commits as you work unless explicitly told not to commit.
- Before committing, make a small effort to verify changes work when reasonable (e.g., run a linter, execute a relevant command, check syntax). Don't skip this just to move faster.
- Before committing to the main/master branch, always ask for confirmation first.
- When finished, summarize what was done so the work can be reviewed in a pull request.

# Production Safety

The following commands interact with production systems: heroku, railway, gcloud, gh, terraform, kubectl, k9s, ssh.

- You may use these tools for read-only operations (viewing logs, listing resources, checking status).
- Never run commands that could modify production state without explicit confirmation.
- If you are unsure whether a command is read-only, ask first.

# Git Safety

- Avoid destructive git commands (reset --hard, clean -f, stash drop/clear, push --force, branch -D, checkout -- .).
- If a destructive git command is truly necessary, explain why and ask for confirmation first.
- Prefer safe alternatives: create a backup branch before resetting, use git stash instead of discarding changes.
