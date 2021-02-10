#!/usr/bin/env bash

# install ansible
sudo apt upgrade --assume-yes
sudo apt install --assume-yes git software-properties-common python-is-python3 ansible

# install chezmoi
wget --no-clobber https://github.com/twpayne/chezmoi/releases/download/v1.8.11/chezmoi_1.8.11_linux_amd64.deb -O /tmp/chezmoi.deb
sudo apt install /tmp/chezmoi.deb

# init and apply chezmoi
git clone -b regolith git@github.com:alanchrt/dotfiles.git ~/.local/share/chezmoi
chmod 0700 ~/.local/share/chezmoi/
chezmoi apply
