#!/usr/bin/env bash

ROOT=${ROOT:-/mnt}

rebuild_nixos() {
    echo "Rebuilding NixOS..."
    # TODO NIXOS-BRANCH update this path after master merge
    curl https://raw.githubusercontent.com/alanctkc/dotfiles/nixos/configuration.nix > /tmp/configuration.nix
    mkdir -p $ROOT/etc/nixos
    mv -f /tmp/configuration.nix $ROOT/etc/nixos/configuration.nix
    nixos-generate-config --root "$ROOT" --show-hardware-config > $ROOT/etc/nixos/hardware-configuration.nix
    nixos-install --root "$ROOT"
}

configure_password() {
    echo "Configuring user password..."
    passwd --root "$ROOT" alan
}

setup_home() {
    echo "Setting up home directory structure..."
    create_path $ROOT/home/alan/.gnupg
    create_path $ROOT/home/alan/.config
    create_path $ROOT/home/alan/Downloads
    create_path $ROOT/home/alan/Dropbox/Notes
    create_path $ROOT/home/alan/Workspaces
}

activate_system() {
    echo "Activating mounted NixOS system..."
    chroot $ROOT /nix/var/nix/profiles/system/activate
    mkdir -p $ROOT/home/alan/.gnupg
    chown 1000:users $ROOT/home/alan/.gnupg
}

retrieve_dotfiles() {
    echo "Retrieving dotfiles..."
    # which git || nix-env -f "<nixpkgs>" -iA git
    if [ ! -d /home/alan/.config/dotfiles ]; then
        git clone https://github.com/alanctkc/dotfiles.git /home/alan/.config/dotfiles
    fi
    # TODO NIXOS-BRANCH delete following two lines after master merge
    git -C /home/alan/.config/dotfiles fetch origin nixos
    git -C /home/alan/.config/dotfiles checkout nixos
    git -C /home/alan/.config/dotfiles remote rm alanctkc || true
    git -C /home/alan/.config/dotfiles remote add alanctkc git@github.com:alanctkc/dotfiles.git
    chown 1000:users /home/alan/.config/dotfiles
}

install_dotfiles() {
    echo "Installing dotfiles..."
    su alan -c "mkdir -p /home/alan/.config"
    if [ ! -d /home/alan/.config/dotfiles ]; then
        su alan -c "git clone https://github.com/alanctkc/dotfiles.git /home/alan/.config/dotfiles"
    fi
    su alan -c "git -C /home/alan/.config/dotfiles remote rm alanctkc || true"
    su alan -c "git -C /home/alan/.config/dotfiles remote add alanctkc git@github.com:alanctkc/dotfiles.git"
    # TODO NIXOS-BRANCH delete following two lines after master merge
    su alan -c "git -C /home/alan/.config/dotfiles fetch alanctkc nixos"
    su alan -c "git -C /home/alan/.config/dotfiles checkout nixos"
    rm /etc/nixos/configuration.nix
    ln -sf /home/alan/.config/dotfiles/configuration.nix /etc/nixos/configuration.nix
    su alan -c "cd /home/alan/.config/dotfiles && ./dotme.sh"
}

set -e

rebuild_nixos
configure_password
setup_home
activate_system
export -f retrieve_dotfiles
chroot "$ROOT" /run/current-system/sw/bin/bash -c "retrieve_dotfiles"
export -f install_dotfiles
chroot "$ROOT" /run/current-system/sw/bin/bash -c "install_dotfiles"
