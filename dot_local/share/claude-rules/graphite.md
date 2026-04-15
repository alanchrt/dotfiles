---
description: Graphite stacking workflow for team projects — symlink this file into .claude/rules/
---

# Graphite Workflow

This project uses Graphite for stacked PRs. Use `gt` instead of `git branch` / `gh pr create`.

## When Graphite rules are present, override these global defaults:

- Do NOT use worktrees — Graphite stacks are sequential dependent branches that should be managed in the main checkout
- Do NOT use `gh pr create` — Graphite manages PR creation
- Do NOT manually delete branches — `gt sync` cleans up after merge

## Creating changes

- Use `gt create -m "description"` to create a new branch with staged changes
- Each `gt create` becomes one PR in the stack — keep changes small and focused
- Use `gt modify -m "updated description"` to amend the current branch
- Use `gt restack` to update branches above after modifying a lower branch

## Submitting for review

- Use `gt submit --stack` to create/update PRs for the entire stack
- Use `gt submit` (no --stack) to submit only the current branch

## Navigating stacks

- `gt up` / `gt down` — move between branches in a stack
- `gt log short` — see the current stack
- `gt trunk` — return to the main branch

## Syncing

- `gt sync` — pull latest trunk, restack all branches, clean up merged

## Safety

- Never use `gt submit --force` without confirmation — it force-pushes
- Never use `gt repo init --force` without confirmation — it resets metadata
- Never use `gt branch delete` on branches you didn't create
