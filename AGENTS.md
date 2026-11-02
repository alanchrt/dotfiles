# Dotfiles repository workflow

- Treat this repository as the source of truth for persistent machine and user configuration. Prefer expressing fixes in Ansible roles, chezmoi-managed files/templates, bootstrap tasks, or repository documentation so they can be replayed on another machine.
- Diagnose the live system freely with read-only commands, but do not treat one-off host edits—such as `dconf`, `gsettings`, package, extension, service, or file changes—as the final fix when the state belongs in this repository.
- When a live change is needed for validation, make the corresponding repository change first or alongside it, and clearly distinguish temporary validation from the durable fix. Apply the configuration to the host only when the user explicitly requests it or it is necessary to verify the repository change.
