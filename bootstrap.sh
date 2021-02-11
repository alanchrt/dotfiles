#!/usr/bin/env bash

# install base deps
sudo apt upgrade --assume-yes
sudo apt install --assume-yes git curl software-properties-common python-is-python3 ansible build-essential libssl-dev
mkdir -p /tmp/dotfiles

# install chezmoi
wget --no-clobber https://github.com/twpayne/chezmoi/releases/download/v1.8.11/chezmoi_1.8.11_linux_amd64.deb -O /tmp/dotfiles/chezmoi.deb
sudo apt install /tmp/dotfiles/chezmoi.deb

# init and apply chezmoi
if [ ! -d ~/.local/share/chezmoi ] ; then
    git clone -b regolith git@github.com:alanchrt/dotfiles.git ~/.local/share/chezmoi
    chmod 0700 ~/.local/share/chezmoi/
fi
chezmoi apply

# install ansible galaxy dependencies
ansible-galaxy collection install community.general
wget --no-clobber -O /tmp/dotfiles/requirements.yml https://raw.githubusercontent.com/alanchrt/dotfiles/regolith/requirements.yml
ansible-galaxy install -r /tmp/dotfiles/requirements.yml

# run ansible playbook
# test locally: ansible-playbook --ask-become-pass -c local local.yml -i hosts
ansible-pull --checkout regolith --url git@github.com:alanchrt/dotfiles.git --ask-become-pass
