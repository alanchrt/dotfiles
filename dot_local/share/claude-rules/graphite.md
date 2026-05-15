---
description: Graphite stacking workflow for team projects — enable per project with `wst gtinit`
---

# Graphite Workflow

This project uses Graphite for stacked PRs. Use `gt` instead of plain `git`/`gh` for branch creation, restacking, and PR submission. Graphite works *inside* a workstream (see CLAUDE.md "Workstream Workflow") — each stream is a separate clone, so `gt`'s metadata stays clean per-stream.

## Where to run gt

Run `gt` inside the stream's devcontainer (the pane you land in after `wa <branch>`). Each stream gets its own gt metadata, so stacks created in one stream don't collide with stacks in another. The host-side canonical at `~/Projects/<project>/main/` is for navigation; don't run gt there during stream work.

## Overrides

- Do NOT use `gh pr create` — Graphite manages PR creation
- Do NOT use `git branch` / `git checkout -b` — use `gt create` instead
- Do NOT manually delete branches — `gt sync` cleans up after merge
- Do NOT use `git rebase` — use `gt restack` instead

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
- `gt checkout <branch>` — switch to a different stack

## Syncing

- `gt sync` — pull latest trunk, restack all branches, clean up merged

## Safety

- Never use `gt submit --force` without confirmation — it force-pushes
- Never use `gt repo init --force` without confirmation — it resets metadata
- Never use `gt branch delete` on branches you didn't create
