#!/usr/bin/env bash

# install ansible
sudo apt upgrade --assume-yes
sudo apt install --assume-yes software-properties-common python-is-python3 ansible

# install chezmoi
wget --no-clobber https://github.com/twpayne/chezmoi/releases/download/v1.8.11/chezmoi_1.8.11_linux_amd64.deb -O /tmp/chezmoi.deb
sudo apt install /tmp/chezmoi.deb

# init chezmoi
chezmoi init "git@github.com:alanchrt/dotfiles.git#regolith"
