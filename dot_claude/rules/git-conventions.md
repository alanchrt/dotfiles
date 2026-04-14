---
description: Global git conventions for all projects
---

- Write commit messages in imperative mood ("Add feature", not "Added feature")
- Keep the first line under 72 characters
- Use the body for "why", not "what" — the diff shows the what
- Prefer small, focused commits over large omnibus commits
- Never commit secrets, credentials, or .env files
- Do not use heredocs (cat <<'EOF') in git commit -m commands — use `-m "subject" -m "body"` for multi-line messages instead
