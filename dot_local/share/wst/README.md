# wst

`wst` creates isolated workstreams as separate git clones under
`~/Projects/<project>/<stream>/` and opens each stream in its own tmux window.
Panes run directly on the host in the stream clone with
`WST_PROJECT`, `WST_STREAM`, `WST_PORT`, `WST_HOST_PORT`, and
`WST_CDP_PORT`, and `WST_BROWSER_PROFILE` exported.

## Commands

```bash
wst clone <git-url> [name]                         # clone into ~/Projects/<name>/main/
wst new <branch> [--base <base>] [--purpose <text>]
                                                    # create stream + tmux window
wst attach <branch>                                # switch to stream window
wst preview [<branch>]                             # open http://localhost:<port>/
wst ls [--all]                                     # list streams
wst resources [--apply] [<branch>]                 # inspect/apply pane limits
wst park <branch>                                  # stop panes; preserve clone/state
wst rm <branch> [--force]                          # remove stream clone/window/state
wst gtinit [--project <name>]                      # enable Graphite rules
wst purpose [--set <text> | --clear]               # manage the persistent Codex purpose
wst codex [codex options...]                       # start Codex with the stream purpose
wst chrome [-- <url> ...]                          # browser handoff profile
wst doctor                                         # diagnostics
```

## Persistent Codex Purpose

Each stream can store a durable purpose in its clone-local Git config. This
value is not committed. WST injects it as a Codex developer instruction each
time it starts Codex.

```bash
wst purpose --set "Fix product defects and add focused regression tests."
wst purpose
wst codex
```

You can also set the purpose when you create a stream:

```bash
wst new bugs --purpose "Fix product defects and add focused regression tests."
```

After you change a purpose, exit the current Codex CLI once and start it with
`wst codex`. Then use `/new <task>` or `/clear <task>` between unrelated tasks.
The new chat drops the old task context, but it keeps the stream purpose from
the WST launch configuration. If no explicit purpose exists, WST uses the
stream name as the purpose.

## Tmux Layout

`wst new` opens this workspace layout:

- top-left: Codex
- top-right: spare shell
- bottom: Magit by default

Set `WST_PANES=1` for a single pane. Set `WST_GIT_PANE=lazygit` or
`WST_GIT_PANE=shell` to replace the Magit pane. Stream-aware tmux splits
(`prefix + "` and `prefix + %`) open in the current stream.

## Resource Controls

Every WST pane runs in its own systemd scope with a lower CPU/IO scheduling
weight than desktop applications. Memory pressure starts at 6 GiB for agent
panes, 3 GiB for editor panes, and 8 GiB for shell/build panes; hard limits are
10 GiB, 5 GiB, and 12 GiB respectively. These limits keep one runaway stream
from making Chrome, calls, or the desktop unresponsive.

New panes receive the policy automatically. Apply it to panes that were already
open when the dotfiles changed, and inspect current/peak usage, with:

```bash
wst resources --apply
wst resources                 # all active streams
wst resources my-stream       # one stream
```

Park inactive streams instead of leaving their agents and language servers in
memory. Parking closes the tmux window and its Emacs daemon, but preserves the
clone, Git changes, port, and stream configuration:

```bash
wst park my-stream
wa my-stream                  # recreate the panes later
```

## Chrome DevTools MCP

When Codex needs browser access through Chrome DevTools MCP, run this in a
sibling stream pane first:

```bash
wst chrome >/tmp/wst-chrome.log 2>&1 &
```

WST uses the persistent `~/.config/chromium-wst` profile and launches Chrome
with remote debugging enabled on `$WST_CDP_PORT` so Codex's `chrome-devtools`
MCP server can attach to it.

For SSO, MFA, captchas, or consent screens, complete the interactive flow in
that Chrome window, then tell the agent to retry.

## Troubleshooting

| Symptom | Fix |
|---|---|
| commit rejected: "refusing to commit on trunk" | Streams open on trunk synced to origin; create the feature branch first with `git switch -c "$WST_STREAM"` or `gt create -m "..."`. |
| `wst chrome` cannot find Chromium | Install Chromium or Chrome on the host. |
| A new Codex chat does not know the stream purpose | Exit the CLI with `/quit`, then run `wst codex` once. Future `/new` and `/clear` chats retain it. |
