# wst

`wst` creates isolated workstreams as separate git clones under
`~/Projects/<project>/<stream>/` and opens each stream in its own tmux window.
The default runtime is the host: panes run directly in the stream clone with
`WST_PROJECT`, `WST_STREAM`, `WST_PORT`, `WST_HOST_PORT`, and
`WST_CDP_PORT`, and `WST_BROWSER_PROFILE` exported.

## Commands

```bash
wst clone <git-url> [name]                         # clone into ~/Projects/<name>/main/
wst new <branch> [--base <base>] [--devcontainer]  # create stream + tmux window
wst attach <branch> [--devcontainer]               # switch to stream window
wst preview [<branch>]                             # open http://localhost:<port>/
wst ls [--all]                                     # list streams
wst rm <branch> [--force]                          # remove stream clone/window/state
wst gtinit [--project <name>]                      # enable Graphite rules
wst chrome [-- <url> ...]                          # browser handoff profile
wst doctor                                         # diagnostics
```

Use `--devcontainer` only when a stream needs container isolation or a project
runtime that is not installed on the host. The choice is persisted in the stream
git config as `wst.runtime`.

## Tmux Layout

`wst new` opens the same workspace layout for host and devcontainer streams:

- top-left: Codex
- top-right: spare shell
- bottom: Magit by default

Set `WST_PANES=1` for a single pane. Set `WST_GIT_PANE=lazygit` or
`WST_GIT_PANE=shell` to replace the Magit pane. Stream-aware tmux splits
(`prefix + "` and `prefix + %`) open in the current stream runtime.

## Chrome DevTools MCP

When Codex needs browser access through Chrome DevTools MCP, run this in a
sibling stream pane first:

```bash
wst chrome >/tmp/wst-chrome.log 2>&1 &
```

Host streams use `~/.config/chromium-wst`. Devcontainer streams use the
devcontainer profile configured by `wst-container-up`. Both launch Chrome with
remote debugging enabled on `$WST_CDP_PORT` so Codex's `chrome-devtools` MCP
server can attach to it.

For SSO, MFA, captchas, or consent screens, complete the interactive flow in
that Chrome window, then tell the agent to retry.

## Devcontainer Opt-In

Devcontainer streams still use the `wst-dev:latest` mega image and the existing
`wst-container-up`/`wst-devcontainer-exec` helpers.

Build or refresh the image when needed:

```bash
ansible-playbook -i ~/Projects/dotfiles/master/hosts ~/Projects/dotfiles/master/local.yml --tags wst-dev
ansible-playbook -i ~/Projects/dotfiles/master/hosts ~/Projects/dotfiles/master/local.yml --tags wst-dev \
  -e wst_dev_force_rebuild=true
```

Create or attach with a devcontainer:

```bash
wst new my-stream --devcontainer
wst attach my-stream --devcontainer
```

## Troubleshooting

| Symptom | Fix |
|---|---|
| commit rejected: "refusing to commit on trunk" | Streams open on trunk synced to origin; create the feature branch first with `git switch -c "$WST_STREAM"` or `gt create -m "..."`. |
| `wst chrome` cannot find Chromium | Install host Chromium/Chrome, or use a devcontainer stream with `--devcontainer`. |
| devcontainer stream fails: "base image wst-dev:latest not built" | Run the Ansible `--tags wst-dev` command above. |
| `wst ls` shows `devcontainer:down` | Attach with `wa <branch>` to boot the devcontainer, or switch back to host by setting `git config wst.runtime host` in the stream clone. |
