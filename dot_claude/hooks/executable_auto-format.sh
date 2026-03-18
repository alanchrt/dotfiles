#!/usr/bin/env bash
# PostToolUse hook: auto-format edited files if the repo has the formatter configured.
# Also runs shellcheck on .sh/.bash files and ansible-lint on ansible files.
# Reads tool input JSON from stdin. Exits 0 always (formatting failures don't block).

set -euo pipefail

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty')

if [[ -z "$FILE" || ! -f "$FILE" ]]; then
  exit 0
fi

EXT="${FILE##*.}"
BASENAME=$(basename "$FILE")
REPO_ROOT=$(git -C "$(dirname "$FILE")" rev-parse --show-toplevel 2>/dev/null || true)

if [[ -z "$REPO_ROOT" ]]; then
  exit 0
fi

# --- Formatting ---

case "$EXT" in
  js|ts|tsx|jsx|css|json)
    # Only format if prettier is configured in the repo
    if [[ -f "$REPO_ROOT/.prettierrc" ]] || \
       [[ -f "$REPO_ROOT/.prettierrc.json" ]] || \
       [[ -f "$REPO_ROOT/.prettierrc.yml" ]] || \
       [[ -f "$REPO_ROOT/.prettierrc.yaml" ]] || \
       [[ -f "$REPO_ROOT/.prettierrc.js" ]] || \
       [[ -f "$REPO_ROOT/.prettierrc.cjs" ]] || \
       [[ -f "$REPO_ROOT/.prettierrc.mjs" ]] || \
       [[ -f "$REPO_ROOT/prettier.config.js" ]] || \
       [[ -f "$REPO_ROOT/prettier.config.cjs" ]] || \
       [[ -f "$REPO_ROOT/prettier.config.mjs" ]] || \
       grep -q '"prettier"' "$REPO_ROOT/package.json" 2>/dev/null; then
      npx prettier --write "$FILE" 2>/dev/null || true
    fi
    ;;
  py)
    # Only format if ruff is configured
    if [[ -f "$REPO_ROOT/ruff.toml" ]] || \
       [[ -f "$REPO_ROOT/.ruff.toml" ]] || \
       grep -q '\[tool\.ruff\]' "$REPO_ROOT/pyproject.toml" 2>/dev/null; then
      ruff format "$FILE" 2>/dev/null || true
    fi
    ;;
  go)
    # Format if it's a Go project
    if [[ -f "$REPO_ROOT/go.mod" ]]; then
      gofmt -w "$FILE" 2>/dev/null || true
    fi
    ;;
esac

# --- Shell linting ---

case "$EXT" in
  sh|bash)
    if command -v shellcheck &>/dev/null; then
      shellcheck "$FILE" 2>/dev/null || true
    fi
    ;;
esac

# Also lint files with shell shebangs but different extensions
case "$BASENAME" in
  *.sh|*.bash) ;; # already handled above
  *)
    if head -1 "$FILE" 2>/dev/null | grep -qE '^#!/.*(bash|sh)'; then
      if command -v shellcheck &>/dev/null; then
        shellcheck "$FILE" 2>/dev/null || true
      fi
    fi
    ;;
esac

# --- Ansible linting ---

# Lint yml files under roles/ or ansible-related directories
case "$FILE" in
  */roles/*|*/playbooks/*|*/group_vars/*|*/host_vars/*)
    if [[ "$EXT" == "yml" || "$EXT" == "yaml" ]]; then
      if command -v ansible-lint &>/dev/null; then
        ansible-lint "$FILE" 2>/dev/null || true
      fi
    fi
    ;;
esac

exit 0
