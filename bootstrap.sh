#!/usr/bin/env bash

rebuild_nixos() {
    echo "Rebuilding NixOS..."
    # TODO NIXOS-BRANCH update this path after master merge
    curl https://raw.githubusercontent.com/alanctkc/dotfiles/nixos/configuration.nix > /tmp/configuration.nix
    mv -f /tmp/configuration.nix /etc/nixos/configuration.nix
    nixos-generate-config --show-hardware-config > /etc/nixos/hardware-configuration.nix
    nixos-rebuild switch
}

setup_home() {
    echo "Setting up home directory structure..."
    mkdir -p /home/alan/Downloads
    mkdir -p /home/alan/Dropbox/Notes
    mkdir -p /home/alan/Workspaces
}

install_dotfiles() {
    echo "Installing dotfiles..."
    su alan -c 'mkdir -p /home/alan/.config'
    if [ ! -d /home/alan/.config/dotfiles ]; then
        su alan -c 'git clone https://github.com/alanctkc/dotfiles.git /home/alan/.config/dotfiles'
    fi
    su alan -c 'git -C /home/alan/.config/dotfiles remote rm alanctkc || true'
    su alan -c 'git -C /home/alan/.config/dotfiles remote add alanctkc git@github.com:alanctkc/dotfiles.git'
    # TODO NIXOS-BRANCH delete following two lines after master merge
    su alan -c 'git -C /home/alan/.config/dotfiles fetch alanctkc nixos'
    su alan -c 'git -C /home/alan/.config/dotfiles checkout nixos'
    rm /etc/nixos/configuration.nix
    ln -sf /home/alan/.config/dotfiles/configuration.nix /etc/nixos/configuration.nix
    su alan -c 'cd /home/alan/.config/dotfiles && ./dotme.sh'
}

set -e

rebuild_nixos
setup_home
install_dotfiles
