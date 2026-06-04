# Workflow

- For any non-trivial implementation, **start in plan mode** (`/plan` in Codex, plan mode in Claude Code) and produce a plan before writing code.
- In plan mode, do not Edit/Write or run state-mutating Bash (no installs, commits, pushes, file moves, network writes). If a real change is needed to validate the plan, ask first.
- Once you begin implementation, be independent until finished. Do not ask unnecessary questions mid-task.
- Group work into coherent, reviewable PR-sized changes unless explicitly told to split smaller.
  - If `AGENTS.override.md` or `.claude/rules/graphite.md` exists at the repo root with Graphite verbs, use `gt create -m "..."` instead of `git commit`. Same swaps: `gt modify` for `git commit --amend`, `gt create <name>` for `git checkout -b <name>`, `gt restack` for `git rebase`, `gt submit` for `gh pr create`. See that rule file for the full verb table.
- Before committing to the main/master branch, always ask for confirmation first. (This does not apply when working in a worktree on a feature branch.)

# Commit + push flow

**Staging vs committing:** Stage (`git add`) freely and without asking — whenever work is ready to review, stage it immediately. Do NOT commit without explicit user confirmation. Never. Staging is where the user reviews; committing requires their sign-off.

Agents are configured for autonomy with one review gate, at staging. The flow is **one confirmation, then commit and push happen back-to-back with no further prompts**:

1. When a coherent body of work is ready for review — feature complete, bug fixed, or refactor consolidated with its tests/docs — stage the relevant files (`git add ...`).
2. Print `git diff --cached` so the user can review what's about to land.
3. Propose a commit message and ask **once** for confirmation to commit + push.
4. On confirmation, run commit and push back-to-back without further prompts:
   - Plain git: `git commit -m "..." && git push -u origin HEAD`
   - Graphite (when `AGENTS.override.md` or `.claude/rules/graphite.md` is at the repo root): `gt create -m "..." && gt submit`

Prefer one coherent PR over many tiny PRs. Accumulate related edits until the change has a clear review boundary, while avoiding unrelated work in the same PR.

The separate "ask before committing to main/master" rule above still applies; that case is unusual and out-of-band.

# Shared host files

When the user refers to "the screenshot", "that file I downloaded", or otherwise points to a file by description without a path, check these locations first:

- `~/Downloads/` — files the user dropped from host browsers/apps. Same path on the host and inside every stream container (bind-mounted).
- Screenshots: `~/Pictures/Screenshots/` on the host, `~/Screenshots/` inside stream containers (bind-mounted from `~/Pictures/Screenshots/`, flattened for a shorter path).

Both mounts are read-only inside containers — read freely, but don't try to modify them in place.

# TypeScript

When working in TypeScript or JavaScript, use the TypeScript MCP server for type-aware navigation and edits: diagnostics, definitions, references, hover/type info, rename, organize imports, and code actions. Use `rg` and file reads for broad text search, repository exploration, and non-code files. Always verify meaningful TypeScript changes with the project's normal typecheck/test/lint commands when available. If the MCP server is unavailable, stale, or slow, fall back to shell tools.

# Workstream Workflow

Streams are isolated parallel development environments — each one is its own git clone in its own devcontainer with its own port. Stream layout: `~/Projects/<project>/main/` is the canonical, `~/Projects/<project>/<branch>/` are streams. The user manages stream lifecycle manually; don't propose creating or tearing down streams unsolicited.

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

- All commits, PRs, dev server runs, and agent invocations live *inside the container* — that's the pane `wa` drops you into. The host clones exist for filesystem navigation only.
- Default to plain `git` + `gh`. If `AGENTS.override.md` or `.claude/rules/graphite.md` exists at the repo root with Graphite verbs, use `gt` inside the container instead — specifically: `gt create -m "..."` (not `git commit`), `gt modify` (not `git commit --amend`), `gt create <name>` (not `git checkout -b`), `gt restack` (not `git rebase`), `gt submit` (not `gh pr create`). To enable Graphite for a project, run `wst gtinit` once — it links the rule files into the canonical and every existing stream, and runs `gt repo init` in each running container. Future `wst new` streams inherit the setup automatically.
- Push: `git push -u origin HEAD` — the stream branch already has the final name, no prefix mapping.
- After merge: `wst rm <branch>` removes the container, the clone dir, the tmux window, and frees the port.

**Tmux integration:** stream windows split into the same container (`prefix + "` / `prefix + %`). Non-stream windows split normally on the host. The split-pane helper is at `~/.local/bin/wst-tmux-split`.

**Android emulator:** the emulator runs on host (KVM access). Containers reach it through `ADB_SERVER_SOCKET=tcp:host.docker.internal:5037` (set automatically by `wst-container-up`). Host adb listens on all interfaces via the `adb-bridge` systemd user service. Run `adb devices` inside the container to verify the host emulator is visible.

**Chromium / Playwright MCP handoff:** Chromium runs inside the wst-dev container with a persistent profile at `$WST_BROWSER_PROFILE` (Docker volume `wst-chromium-profile`, shared across every stream). When driving the browser via `@playwright/mcp` and hit an SSO / MFA / captcha / consent flow you can't complete on your own, **stop and ask the user to run `wst chrome` in a sibling tmux pane** — that opens a headed Wayland Chromium against the same profile, the user clicks through, closes the window, and the auth state now persists for your headless session. Tell them the exact URL and what they need to do. After they confirm, retry the navigation. See `~/.local/share/wst/README.md` for the full workflow.

# Production Safety

The following commands interact with production systems: heroku, railway, gcloud, gh, terraform, kubectl, k9s, ssh.

- You may use these tools for read-only operations (viewing logs, listing resources, checking status).
- Never run commands that could modify production state without explicit confirmation.
- If you are unsure whether a command is read-only, ask first.

# Git Safety

- Avoid destructive git commands (reset --hard, clean -f, stash drop/clear, push --force, branch -D, checkout -- .).
- If a destructive git command is truly necessary, explain why and ask for confirmation first.
- Prefer safe alternatives: create a backup branch before resetting, use git stash instead of discarding changes.
