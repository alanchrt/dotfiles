# wst-dev

One mega Docker image (`wst-dev:latest`) used as the base for every wst
stream. Replaces the per-project devcontainer base, eliminating the
75-150s per-stream provisioning step. Built once via Ansible, refreshed
on a cadence.

## What's baked in

- **Dev CLIs**: `claude`, `gh`, `gt` (Graphite), `chezmoi`, `mise`
- **Runtimes**: Node 22 (NodeSource), Bun 1.3.5, OpenJDK 17 (Adoptium temurin)
- **Mobile**: Android cmdline-tools 11076708 + platform-tools, build-tools 34.0.0, platforms/android-34, emulator
- **Browser stack**: Playwright + Chromium (system-wide, at `/opt/playwright-browsers`), `@playwright/mcp`, full Chromium runtime libs, Wayland support libs (`wl-clipboard`, `libwayland-*`), GTK+Electron deps
- **Utilities**: `jq`, `ripgrep`, `fd-find`, `fzf`, `build-essential`, `postgresql-client`, `sqlite3`, `inotify-tools`, `xdg-utils`
- **Container tooling**: `@devcontainers/cli`

The image swap is performed in `wst-container-up`: the project's
`devcontainer.json` keeps its `mounts`, `forwardPorts`, `containerEnv`,
`runArgs`, and `postCreateCommand` — but `image`, `build`, and `features`
are replaced with `image: wst-dev:latest`.

Projects without a devcontainer use the central fallback config at
`~/.local/share/wst/default-devcontainer/devcontainer.json`. It is intentionally
minimal and generic; `wst-container-up` still injects the usual mounts, env,
port forwarding, and `wst-dev-entrypoint`.

## Build / refresh

```bash
ansible-playbook ~/Projects/dotfiles/master/local.yml --tags wst-dev
# Force rebuild (e.g. after a Claude/gh release you want):
ansible-playbook ~/Projects/dotfiles/master/local.yml --tags wst-dev \
  -e wst_dev_force_rebuild=true
```

The first build takes ~5-10 min (Android SDK is the slow layer). Subsequent
runs without `wst_dev_force_rebuild=true` are no-ops if the Dockerfile
hasn't changed.

## What gets mounted into every stream

| Host path | Container path | Mode | Purpose |
|---|---|---|---|
| `~/Projects/dotfiles/master` | `~/Projects/dotfiles/master` | rw | chezmoi source — applied on container start |
| `~/Projects/Shared` | `~/Shared` | rw | drop files here on host, see them in any stream |
| `~/.local/share/wst/mise` | `~/.local/share/mise` | rw | mise install cache, shared across all streams |
| `~/.ssh/id_ed25519*` | `~/.ssh/...` | ro | git over SSH |
| `~/.gitconfig` | `~/.host-gitconfig` | ro | included by the wst layer gitconfig |
| `~/.config/graphite/auth` | `~/.config/graphite/auth` | ro | Graphite auth — shared from host |
| `~/.config/graphite/aliases` | `~/.config/graphite/aliases` | ro | Graphite aliases — shared from host |
| `~/.claude/` | `~/.claude/` | rw | Claude Code config + credentials (also shared) |
| `~/.claude.json` | `~/.claude.json` | rw | Claude Code user state |
| `~/Downloads/` | `~/Downloads/` | ro | host downloads, browseable |
| `~/Pictures/Screenshots/` | `~/Screenshots/` | ro | host screenshots, browseable |
| `wst-chromium-profile` (volume) | `~/.config/chromium-wst` | rw | persistent Chromium profile — auth/cookies live here |
| `wst-chrome-<project>` (volume) | `~/.config/chromium` | rw | per-project Chromium runtime data |
| `/var/run/docker.sock` | `/var/run/docker.sock` | rw | for sibling compose services |
| Host Wayland socket | `/run/user/1000/<wayland>` | rw | for headed Chromium handoff |

GitHub auth is forwarded via `GITHUB_TOKEN` (sourced from `gh auth token`
on the host). The entrypoint runs `gh auth login --with-token` on each
container start, so every stream is logged in as you.

## mise workflow (across streams)

1. Drop `.mise.toml` (or `.tool-versions`) into any project.
2. `wst-dev-entrypoint` runs `mise install` on container start.
3. The install lands in `~/.local/share/mise/installs/` which is
   bind-mounted from `~/.local/share/wst/mise` on the host.
4. A tool installed in stream A is immediately available in stream B —
   no re-download.

Use `mise use node@20` (etc.) inside any stream; the change persists to
the project's `.mise.toml` and the install cache survives forever.

## Browser handoff workflow (SSO / interactive flows)

When Claude is driving Chromium via `@playwright/mcp` and hits a wall it
can't get past on its own — SSO, MFA, captcha, a consent screen — here's
what you do.

### From Claude's side

Claude will tell you it needs human interaction at a specific URL. Look
for a message like:

> I need you to complete SSO at `https://accounts.google.com/...`. Run
> `wst chrome` in another pane, log in, then close the window — I'll
> retry the navigation.

### Your steps

1. Open a new tmux pane (`prefix + "` or `prefix + %`) — this opens
   inside the same stream container.
2. Run:

   ```bash
   wst chrome
   ```

   A Chromium window appears on your desktop (via Wayland forwarding),
   using the persistent profile at `~/.config/chromium-wst` (volume
   `wst-chromium-profile`).
3. Navigate to the URL Claude gave you, complete the login flow.
4. Close the Chromium window. Cookies and session storage are now
   persisted in the volume.
5. Tell Claude to retry — its Playwright session, pointing at the same
   profile, now has the authenticated state.

### Re-running auth

The profile persists forever. If you ever need to start over (corrupt
state, want to log out everywhere):

```bash
docker volume rm wst-chromium-profile
ansible-playbook ~/Projects/dotfiles/master/local.yml --tags wst-dev
# (the role recreates the empty volume)
```

### Notes

- **Wayland only** — the container expects `WAYLAND_DISPLAY` and a host
  Wayland socket forwarded at `$XDG_RUNTIME_DIR`. On X11 hosts this won't
  work without changes (mount `/tmp/.X11-unix` and pass `DISPLAY`).
- **One headed session at a time** — the shared profile holds a process
  lock. If you have two streams that need headed handoff simultaneously,
  serialize them.
- **The headed Chromium runs in your stream's container** — not a
  separate sidecar. Same container, same Playwright binary, just invoked
  headed via `wst chrome`. Claude's `@playwright/mcp` continues to drive
  headless against the same profile while you have the headed window
  open is *technically* possible (Chromium supports multiple processes
  on one profile if you pass `--user-data-dir` consistently) but is
  fragile — easier to: complete the auth, close the window, then have
  Claude proceed.

## Troubleshooting

| Symptom | Fix |
|---|---|
| `wst new` fails: "image not found: wst-dev:latest" | `ansible-playbook ~/Projects/dotfiles/master/local.yml --tags wst-dev` |
| commit rejected: "refusing to commit on trunk" | Streams open on the trunk (`main`) synced to origin; create a feature branch first (`git switch -c "$WST_STREAM"` or `gt create -m "..."`). The `pre-commit` guard is installed per-stream by `wst new`/`wa`. |
| chezmoi apply errors flood the entrypoint log | Check `~/Projects/dotfiles/master/.chezmoidata.toml` is populated; templates reference its fields |
| `mise install` skips a tool | First run installs binaries to `~/.local/share/mise/installs/`; check that path is writable and the bind mount is in place |
| `wst chrome` errors with "cannot connect to wayland" | Verify `WAYLAND_DISPLAY` on the host, check `$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY` is bind-mounted into the container at `/run/user/1000/` |
| Auth in headed Chromium doesn't persist | Volume `wst-chromium-profile` may have been recreated. Re-do the SSO flow once; subsequent runs persist normally. |
| docker socket permission denied | Add the host user to the `docker` group (`sudo usermod -aG docker $USER`, log out/in) |
