# Workflow

- Always draft a plan before starting implementation work.
- Once you begin working, be independent until finished. Do not ask unnecessary questions mid-task.
- Make small, focused commits as you work unless explicitly told not to commit.
- Before committing to the main/master branch, always ask for confirmation first.
- When finished, summarize what was done so the work can be reviewed in a pull request.

# Production Safety

The following commands interact with production systems: heroku, railway, gcloud, gh, terraform, kubectl, k9s, ssh.

- You may use these tools for read-only operations (viewing logs, listing resources, checking status).
- Never run commands that could modify production state without explicit confirmation.
- If you are unsure whether a command is read-only, ask first.
