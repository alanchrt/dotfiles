---
paths:
  - "dot_*/**"
  - "dot_*"
description: Chezmoi source file conventions
---

- Always edit chezmoi source files (dot_ prefix) in this repo, never deployed files in ~/
- File naming: `dot_bashrc` → `~/.bashrc`, `dot_config/` → `~/.config/`
- Executable scripts use `executable_` prefix
- Template files use `.tmpl` suffix
- Run `chezmoi diff` to verify changes before applying
