#!/usr/bin/env bash
# wst-dev container boot setup. Invoked as the devcontainer.json
# `postStartCommand` by wst-container-up — runs on every container boot.
#
# Idempotent; intentionally returns 0 even when individual steps fail so a
# single transient error doesn't block the user from getting a shell.
#
# 1. Apply dotfiles via chezmoi from the bind-mounted source
# 2. Log gh in from the forwarded GITHUB_TOKEN
# 3. mise activate + auto-install if the project has .mise.toml
# 4. Auto-init Graphite for projects that opted in
# 5. ADB smoke test (non-fatal)
set +e

note() { printf 'wst-dev: %s\n' "$*" >&2; }

# Reclaim ownership of bind-mount parent dirs that `devcontainer up` created
# as root. Without these, chezmoi/mise/etc. hit "permission denied" trying
# to create files under HOME paths whose intermediates are root-owned.
for d in \
    "$HOME/.cache" "$HOME/.cache/wst" \
    "$HOME/.config" "$HOME/.config/gh" "$HOME/.config/graphite" \
    "$HOME/.local" "$HOME/.local/share" "$HOME/.local/bin" \
    "$HOME/.ssh"; do
  [ -d "$d" ] && sudo chown "$USER" "$d" 2>/dev/null || true
done

# 1. chezmoi apply from the bind-mounted dotfiles source. Capture output to
#    a log file so errors are diagnosable (instead of silently discarded).
DOTFILES_SRC="${WST_DOTFILES_SRC:-$HOME/Projects/dotfiles/master}"
CHEZMOI_LOG="$HOME/.cache/wst/chezmoi-apply.log"
mkdir -p "$(dirname "$CHEZMOI_LOG")"
if [[ -d "$DOTFILES_SRC" ]] && command -v chezmoi >/dev/null 2>&1; then
  if ! chezmoi apply --source "$DOTFILES_SRC" --force >"$CHEZMOI_LOG" 2>&1; then
    note "chezmoi apply had errors (non-fatal) — see $CHEZMOI_LOG"
  fi
fi

# 2. gh auth (host's GITHUB_TOKEN is forwarded via remoteEnv)
if [[ -n "${GITHUB_TOKEN:-}" ]] && command -v gh >/dev/null 2>&1; then
  gh auth status >/dev/null 2>&1 \
    || printf '%s' "$GITHUB_TOKEN" | gh auth login --with-token >/dev/null 2>&1 \
    || true
fi

# 3. mise — activate the shim path; install project tools if the cwd has a
#    .mise.toml or .tool-versions. The mise install cache lives in a host
#    bind mount (~/.local/share/wst/mise) so it's shared across all streams.
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate bash 2>/dev/null)" || true
  if [[ -f "${PWD}/.mise.toml" || -f "${PWD}/.tool-versions" ]]; then
    mise install --quiet 2>/dev/null || note "mise install had errors (non-fatal)"
  fi
fi

# 4. Graphite repo init if project opted in
if [[ -f "${PWD}/.claude/rules/graphite.md" ]] && command -v gt >/dev/null 2>&1; then
  trunk=$(git -C "$PWD" symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null | sed 's|^origin/||' || true)
  [[ -n "$trunk" ]] || trunk=$(git -C "$PWD" branch --show-current 2>/dev/null || true)
  [[ -n "$trunk" ]] && gt repo init --trunk "$trunk" >/dev/null 2>&1 || true
fi

# 5. ADB smoke test (non-fatal)
if [[ -n "${ADB_SERVER_SOCKET:-}" ]] && command -v adb >/dev/null 2>&1; then
  adb devices >/dev/null 2>&1 || true
fi

exit 0
