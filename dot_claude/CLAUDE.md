# Workflow

- Always draft a plan before starting implementation work.
- In plan mode, the only writable target is the harness-allocated plan file at `~/.claude/plans/<slug>.md`. Do not Edit/Write/NotebookEdit anywhere else, and do not run Bash commands that mutate state (no installs, commits, pushes, file moves, network writes). If you think a real change is needed to validate the plan, ask via `AskUserQuestion`. Plan mode ends only via `ExitPlanMode`.
- Once you begin working, be independent until finished. Do not ask unnecessary questions mid-task.
- Make small, focused commits as you work unless explicitly told not to commit.
  - If `.claude/rules/graphite.md` exists in the project, use `gt create -m "..."` instead of `git commit`. Same swaps: `gt modify` for `git commit --amend`, `gt create <name>` for `git checkout -b <name>`, `gt restack` for `git rebase`, `gt submit` for `gh pr create`. A PreToolUse hook will block the raw `git`/`gh` form in these projects — see `.claude/rules/graphite.md` for the full verb table.
- Before committing, make a small effort to verify changes work when reasonable (e.g., run a linter, execute a relevant command, check syntax). Don't skip this just to move faster.
- Before committing to the main/master branch, always ask for confirmation first. (This does not apply when working in a worktree on a feature branch.)
- When finished, summarize what was done so the work can be reviewed in a pull request.

# Shared host files

When the user refers to "the screenshot", "that file I downloaded", or otherwise points to a file by description without a path, check these locations first:

- `~/Downloads/` — files the user dropped from host browsers/apps. Same path on the host and inside every stream container (bind-mounted).
- Screenshots: `~/Pictures/Screenshots/` on the host, `~/Screenshots/` inside stream containers (bind-mounted from `~/Pictures/Screenshots/`, flattened for a shorter path).

Both mounts are read-only inside containers — read freely, but don't try to modify them in place.

# Workstream Workflow

Streams are isolated parallel development environments — each one is its own git clone in its own devcontainer with its own port. Stream layout: `~/Projects/<project>/main/` is the canonical, `~/Projects/<project>/<branch>/` are streams.

**Use a stream when:**
- On `main`/`master` and the task is more than a trivial change
- The task is unrelated to the current branch's purpose
- The task would benefit from an isolated PR
- Multiple features need to be developed in parallel

**Don't use a stream when:**
- Small, quick fixes (typos, single-line changes) — edit in `<project>/main/` and ask for confirmation before committing to main
- Already inside an existing stream window (you're attached if `tmux show-options -wqv @wst-stream` returns a value)
- The user explicitly says to work on the current branch

**Commands** (the host `wst` script — see `~/.local/bin/wst`; chezmoi source: `dot_local/bin/executable_wst`):

```bash
wcl <git-url> [name]               # clone repo into ~/Projects/<name>/main/
wst new <branch> [--base <base>]   # clone + container up + tmux window
wa <branch>                        # attach (or boot if stopped) — switches tmux window
wp [<branch>]                      # preview: open localhost:<port>/ in host browser
wls                                # list streams in current project
wst rm <branch>                    # tear down: container + clone dir + tmux window
wst gtinit [--project <name>]      # mark project as Graphite-enabled (one-time per project)
wst doctor                         # diagnostics
```

- All commits, PRs, dev server runs, and Claude Code invocations live *inside the container* — that's the pane `wa` drops you into. The host clones exist for filesystem navigation only.
- Default to plain `git` + `gh`. If `.claude/rules/graphite.md` exists in the project, use `gt` inside the container instead — specifically: `gt create -m "..."` (not `git commit`), `gt modify` (not `git commit --amend`), `gt create <name>` (not `git checkout -b`), `gt restack` (not `git rebase`), `gt submit` (not `gh pr create`). A PreToolUse hook enforces this. To enable Graphite for a project, run `wst gtinit` once — it links the rule into the canonical and every existing stream, and runs `gt repo init` in each running container. Future `wst new` streams inherit the setup automatically.
- Push: `git push -u origin HEAD` — the stream branch already has the final name, no prefix mapping.
- After merge: `wst rm <branch>` removes the container, the clone dir, the tmux window, and frees the port.

**Tmux integration:** stream windows split into the same container (`prefix + "` / `prefix + %`). Non-stream windows split normally on the host. The split-pane helper is at `~/.local/bin/wst-tmux-split`.

**Android emulator:** the emulator runs on host (KVM access). Containers reach it through `ADB_SERVER_SOCKET=tcp:host.docker.internal:5037` (set automatically by `wst-container-up`). Host adb listens on all interfaces via the `adb-bridge` systemd user service. Run `adb devices` inside the container to verify the host emulator is visible.

**Chromium / Playwright MCP handoff:** Chromium runs inside the wst-dev container with a persistent profile at `$WST_BROWSER_PROFILE` (Docker volume `wst-chromium-profile`, shared across every stream). When you're driving the browser via `@playwright/mcp` and hit an SSO / MFA / captcha / consent flow you can't complete on your own, **stop and ask the user to run `wst chrome` in a sibling tmux pane** — that opens a headed Wayland Chromium against the same profile, the user clicks through, closes the window, and the auth state now persists for your headless session. Tell them the exact URL and what they need to do. After they confirm, retry the navigation. See `~/.local/share/wst/README.md` for the full workflow.

# Production Safety

The following commands interact with production systems: heroku, railway, gcloud, gh, terraform, kubectl, k9s, ssh.

- You may use these tools for read-only operations (viewing logs, listing resources, checking status).
- Never run commands that could modify production state without explicit confirmation.
- If you are unsure whether a command is read-only, ask first.

# Git Safety

- Avoid destructive git commands (reset --hard, clean -f, stash drop/clear, push --force, branch -D, checkout -- .).
- If a destructive git command is truly necessary, explain why and ask for confirmation first.
- Prefer safe alternatives: create a backup branch before resetting, use git stash instead of discarding changes.
