#!/usr/bin/env bash

rebuild_nixos() {
    echo "Rebuilding NixOS..."
    # TODO NIXOS-BRANCH update this path after master merge
    curl https://raw.githubusercontent.com/alanctkc/dotfiles/nixos/configuration.nix > /tmp/configuration.nix
    mv -f /tmp/configuration.nix /etc/nixos/configuration.nix
    nixos-rebuild switch
}

install_dotfiles() {
    echo "Installing dotfiles..."
    su alan -c 'mkdir -p /home/alan/.config'
    if [ ! -d /home/alan/.config/dotfiles ]; then
        su alan -c 'git clone https://github.com/alanctkc/dotfiles.git /home/alan/.config/dotfiles'
    fi
    su alan -c 'git -C /home/alan/.config/dotfiles remote rm origin'
    su alan -c 'git -C /home/alan/.config/dotfiles remote add origin git@github.com:alanctkc/dotfiles.git'
    # TODO NIXOS-BRANCH delete following two lines after master merge
    su alan -c 'git -C /home/alan/.config/dotfiles fetch origin nixos'
    su alan -c 'git -C /home/alan/.config/dotfiles checkout nixos'
    rm /etc/nixos/configuration.nix
    ln -sf /home/alan/.config/dotfiles/configuration.nix /etc/nixos/configuration.nix
    su alan -c 'cd /home/alan/.config/dotfiles && ./dotme.sh'
}

set -e

rebuild_nixos
install_dotfiles

echo "Done."
