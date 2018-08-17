#!/usr/bin/env bash

ROOT=${ROOT=:-}

rebuild_nixos() {
    echo "Rebuilding NixOS..."
    # TODO NIXOS-BRANCH update this path after master merge
    curl https://raw.githubusercontent.com/alanctkc/dotfiles/nixos/configuration.nix > /tmp/configuration.nix
    mkdir -p $ROOT/etc/nixos
    mv -f /tmp/configuration.nix $ROOT/etc/nixos/configuration.nix
    nixos-generate-config --root "$ROOT" --show-hardware-config > $ROOT/etc/nixos/hardware-configuration.nix
    if [ -z "$ROOT" ]; then
        nixos-rebuild switch
    else
        nixos-install --root "$ROOT"
    fi
}

configure_password() {
    echo "Configuring user password..."
    if [ ! -z "$ROOT" ]; then
        passwd --root "$ROOT" alan
    fi
}

activate_system() {
    echo "Activating mounted NixOS system..."
    chroot $ROOT /nix/var/nix/profiles/system/activate
    mkdir -p $ROOT/home/alan/.gnupg
    chown 1000:users $ROOT/home/alan/.gnupg
}

setup_home() {
    echo "Setting up home directory structure..."
    su alan -c "mkdir -p $ROOT/home/alan/Downloads"
    su alan -c "mkdir -p $ROOT/home/alan/Dropbox/Notes"
    su alan -c "mkdir -p $ROOT/home/alan/Workspaces"
}

install_dotfiles() {
    echo "Installing dotfiles..."
    su alan -c "mkdir -p $ROOT/home/alan/.config"
    if [ ! -d $ROOT/home/alan/.config/dotfiles ]; then
        su alan -c "git clone https://github.com/alanctkc/dotfiles.git $ROOT/home/alan/.config/dotfiles"
    fi
    su alan -c "git -C $ROOT/home/alan/.config/dotfiles remote rm alanctkc || true"
    su alan -c "git -C $ROOT/home/alan/.config/dotfiles remote add alanctkc git@github.com:alanctkc/dotfiles.git"
    # TODO NIXOS-BRANCH delete following two lines after master merge
    su alan -c "git -C $ROOT/home/alan/.config/dotfiles fetch alanctkc nixos"
    su alan -c "git -C $ROOT/home/alan/.config/dotfiles checkout nixos"
    rm $ROOT/etc/nixos/configuration.nix
    ln -sf $ROOT/home/alan/.config/dotfiles/configuration.nix $ROOT/etc/nixos/configuration.nix
    su alan -c "cd $ROOT/home/alan/.config/dotfiles && ./dotme.sh"
}

set -e

rebuild_nixos
configure_password
if [ -z "$ROOT" ]; then
    activate_system
    export -f setup_home
    chroot "$ROOT" /run/current-system/sw/bin/bash -c "setup_home"
    export -f install_dotfiles
    chroot "$ROOT" /run/current-system/sw/bin/bash -c "install_dotfiles"
else
  setup_home
  install_dotfiles
fi
