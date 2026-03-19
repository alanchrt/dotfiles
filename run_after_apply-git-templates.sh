#!/bin/bash
set -euo pipefail

# Re-initialize repos that have a local hooksPath override so they pick up
# the template hooks. `git init` on an existing repo is safe — it only
# re-applies the template without touching the working tree or history.

template_dir="$HOME/.config/git/templates"
[[ -d "$template_dir/hooks" ]] || exit 0

for repo in "$HOME"/Projects/*/; do
    [[ -d "$repo/.git" ]] || continue

    # Only bother if this repo has a local hooksPath override
    local_hooks_path="$(git -C "$repo" config --local core.hooksPath 2>/dev/null || true)"
    [[ -n "$local_hooks_path" ]] || continue

    # Re-init to install template hooks into .git/hooks/
    git -C "$repo" init --template="$template_dir" -q
done
