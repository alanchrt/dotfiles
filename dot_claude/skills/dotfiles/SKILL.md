---
name: dotfiles
description: Work with this dotfiles repo using chezmoi and ansible conventions
---

# Dotfiles Skill

You are working in a **chezmoi-managed dotfiles repo**. Follow these conventions strictly.

## Chezmoi Conventions

- **Always edit source files** in this repo (with `dot_` prefix), never the deployed files in `~/`
- File naming: `dot_bashrc` → `~/.bashrc`, `dot_config/` → `~/.config/`
- Executable scripts use `executable_` prefix (e.g., `executable_my-script.sh`)
- Template files use `.tmpl` suffix
- After editing, verify with `chezmoi diff` before applying

## Ansible Conventions

- Roles live in `roles/<name>/tasks/main.yml`
- Playbook is `local.yml` — roles are listed there with tags
- Use FQCN for all modules (e.g., `ansible.builtin.dnf`, not `dnf`)
- Use `creates:` guards on install tasks to make them idempotent
- Role dependencies go in `requirements.yml`

## Current State

```
!chezmoi diff --no-pager 2>/dev/null | head -80
```

```
!git status --short
```

## Guidelines

- Keep changes minimal and focused
- Test ansible syntax: `ansible-playbook local.yml --syntax-check`
- Prefer editing existing roles over creating new ones unless the scope is clearly separate
