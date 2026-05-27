---
description: Graphite stacking workflow for team projects — enable per project with `wst gtinit`
---

# Graphite is enabled in this project

**Use these verbs, not raw git/gh:**

| Instead of | Run |
|---|---|
| `git commit -m "..."` | `gt create -m "..."` |
| `git commit --amend` | `gt modify` |
| `git checkout -b foo` / `git switch -c foo` | `gt create foo` |
| `git rebase` | `gt restack` |
| `gh pr create` | `gt submit` (or `gt submit --stack`) |
| `git branch -D foo` (post-merge cleanup) | `gt sync` |

A PreToolUse hook denies the left-hand forms in this project. If the hook fires unexpectedly, run the `gt` equivalent — don't try to work around the deny.

`git status`, `git diff`, `git log`, `git add`, `git push`, and `git rebase --continue|--abort|--skip|--quit` are not affected.

## Where to run gt

Run `gt` inside the stream's devcontainer (the pane you land in after `wa <branch>`). Each stream gets its own gt metadata, so stacks created in one stream don't collide with stacks in another. The host-side canonical at `~/Projects/<project>/main/` is for navigation; don't run gt there during stream work.

## Creating changes

- `gt create -m "description"` — create a new branch with staged changes; each `gt create` becomes one PR in the stack, so keep changes small and focused.
- `gt modify -m "updated description"` — amend the current branch.
- `gt restack` — update branches above after modifying a lower branch.

## Submitting for review

- **Always run `gt sync` before `gt submit`** — pulls latest trunk and restacks your branches against it, so you don't push branches that conflict with main or sit on a stale base.
- `gt submit --stack` — create/update PRs for the entire stack.
- `gt submit` (no `--stack`) — submit only the current branch.

## Navigating stacks

- `gt up` / `gt down` — move between branches in a stack.
- `gt log short` — see the current stack.
- `gt trunk` — return to the main branch.
- `gt checkout <branch>` — switch to a different stack.

## Syncing

- `gt sync` — pull latest trunk, restack all branches, clean up merged.

## Safety

- Never use `gt submit --force` without confirmation — it force-pushes.
- Never use `gt repo init --force` without confirmation — it resets metadata.
- Never use `gt branch delete` on branches you didn't create.
