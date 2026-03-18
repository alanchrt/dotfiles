---
paths:
  - "roles/**"
  - "local.yml"
  - "requirements.yml"
description: Ansible conventions for this dotfiles repo
---

- Use FQCN for all Ansible modules (e.g., `ansible.builtin.copy`, not `copy`)
- Every role needs `tasks/main.yml`
- Use `creates:` guards on install tasks for idempotency
- Add new roles to `local.yml` with appropriate tags
- Role tags follow the pattern: `[role-name, category]` where category is dev or desktop
