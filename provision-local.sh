#!/usr/bin/env bash
ansible-playbook --ask-sudo-pass -i 'localhost,' -c local playbooks/desktop.yml
