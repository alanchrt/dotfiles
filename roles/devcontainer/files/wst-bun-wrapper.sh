#!/usr/bin/env bash
set -euo pipefail

tool_name="$(basename "$0")"
fallback="/opt/bun/bin/$tool_name"

find_bun_project_root() {
  local dir="$PWD"
  while [[ "$dir" != "/" ]]; do
    if [[ -f "$dir/.bun-version" ]]; then
      printf '%s\n' "$dir"
      return 0
    fi
    if [[ -f "$dir/.tool-versions" ]] && grep -Eq '^[[:space:]]*bun[[:space:]]+' "$dir/.tool-versions"; then
      printf '%s\n' "$dir"
      return 0
    fi
    if [[ -f "$dir/.mise.toml" || -f "$dir/mise.toml" ]]; then
      printf '%s\n' "$dir"
      return 0
    fi
    if [[ -f "$dir/package.json" ]] && command -v jq >/dev/null 2>&1; then
      if jq -e '.packageManager? | strings | test("^bun@")' "$dir/package.json" >/dev/null 2>&1; then
        printf '%s\n' "$dir"
        return 0
      fi
    fi
    dir="$(dirname "$dir")"
  done
  return 1
}

if command -v mise >/dev/null 2>&1 && root="$(find_bun_project_root)"; then
  export MISE_TRUSTED_CONFIG_PATHS="${MISE_TRUSTED_CONFIG_PATHS:-/workspaces}"
  export MISE_IDIOMATIC_VERSION_FILE_ENABLE_TOOLS="${MISE_IDIOMATIC_VERSION_FILE_ENABLE_TOOLS:-bun}"
  if (cd "$root" && mise install --quiet bun >/dev/null 2>&1); then
    bun_path="$(cd "$root" && mise which "$tool_name" 2>/dev/null || true)"
    if [[ -n "${bun_path:-}" && -x "$bun_path" && "$bun_path" != "/usr/local/bin/$tool_name" ]]; then
      exec "$bun_path" "$@"
    fi
  fi
fi

exec "$fallback" "$@"
