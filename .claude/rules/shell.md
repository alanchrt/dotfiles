---
paths:
  - "**/*.sh"
  - "dot_zshrc"
  - "dot_bashrc"
description: Shell script conventions
---

- Use `set -euo pipefail` at the top of bash scripts
- Use `shellcheck` conventions — quote variables, avoid word splitting
- Prefer `[[ ]]` over `[ ]` in bash
- Use `command -v` instead of `which` to check for binaries
- Use `$(...)` instead of backticks for command substitution
