#!/usr/bin/env bash

PREFIX=${PREFIX:-}

rebuild_nixos() {
    echo "Rebuilding NixOS..."
    # TODO NIXOS-BRANCH update this path after master merge
    curl https://raw.githubusercontent.com/alanctkc/dotfiles/nixos/configuration.nix > /tmp/configuration.nix
    mv -f /tmp/configuration.nix $PREFIX/etc/nixos/configuration.nix
    nixos-generate-config --show-hardware-config > $PREFIX/etc/nixos/hardware-configuration.nix
    nixos-rebuild switch
}

setup_home() {
    echo "Setting up home directory structure..."
    mkdir -p $PREFIX/home/alan/Downloads
    mkdir -p $PREFIX/home/alan/Dropbox/Notes
    mkdir -p $PREFIX/home/alan/Workspaces
}

install_dotfiles() {
    echo "Installing dotfiles..."
    su alan -c "mkdir -p $PREFIX/home/alan/.config"
    if [ ! -d $PREFIX/home/alan/.config/dotfiles ]; then
        su alan -c "git clone https://github.com/alanctkc/dotfiles.git $PREFIX/home/alan/.config/dotfiles"
    fi
    su alan -c "git -C $PREFIX/home/alan/.config/dotfiles remote rm alanctkc || true"
    su alan -c "git -C $PREFIX/home/alan/.config/dotfiles remote add alanctkc git@github.com:alanctkc/dotfiles.git"
    # TODO NIXOS-BRANCH delete following two lines after master merge
    su alan -c "git -C $PREFIX/home/alan/.config/dotfiles fetch alanctkc nixos"
    su alan -c "git -C $PREFIX/home/alan/.config/dotfiles checkout nixos"
    rm $PREFIX/etc/nixos/configuration.nix
    ln -sf $PREFIX/home/alan/.config/dotfiles/configuration.nix $PREFIX/etc/nixos/configuration.nix
    su alan -c "cd $PREFIX/home/alan/.config/dotfiles && ./dotme.sh"
}

set -e

rebuild_nixos
setup_home
install_dotfiles
