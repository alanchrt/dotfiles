#!/bin/bash -i

set -e

export DOTFILES_INSTALL_PATH="${DOTFILES_INSTALL_PATH:-$HOME/Projects/dotfiles}"

# install base deps
sudo apt upgrade --assume-yes
sudo apt install --assume-yes git curl software-properties-common python-is-python3 ansible build-essential libssl-dev
mkdir -p /tmp/dotfiles

# install chezmoi
if [ ! -f /tmp/dotfiles/chezmoi.deb ] ; then
    wget --no-clobber https://github.com/twpayne/chezmoi/releases/download/v1.8.11/chezmoi_1.8.11_linux_amd64.deb -O /tmp/dotfiles/chezmoi.deb
fi
sudo apt install /tmp/dotfiles/chezmoi.deb

# init and apply chezmoi
mkdir -p $DOTFILES_INSTALL_PATH
if [ ! -d $DOTFILES_INSTALL_PATH ] ; then
    git clone -b regolith git@github.com:alanchrt/dotfiles.git $DOTFILES_INSTALL_PATH
fi
chezmoi apply --source $DOTFILES_INSTALL_PATH

# install ansible galaxy dependencies
ansible-galaxy collection install community.general
if [ ! -f /tmp/dotfiles/requirements.yml ] ; then
    wget --no-clobber -O /tmp/dotfiles/requirements.yml https://raw.githubusercontent.com/alanchrt/dotfiles/regolith/requirements.yml
fi
ansible-galaxy install -r /tmp/dotfiles/requirements.yml

# clean up
rm -r /tmp/dotfiles

# run ansible playbook
ANSIBLE_FORCE_COLOR=true ansible-pull --checkout regolith --url git@github.com:alanchrt/dotfiles.git --ask-become-pass -i hosts
