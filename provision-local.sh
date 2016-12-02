#!/usr/bin/env bash
ansible-playbook --ask-sudo-pass -i inventory -c local playbooks/desktop.yml
