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

create_path() {
    mkdir -p $1
    chown -R 1000:users $1
}

setup_dirs() {
    echo "Setting up directory structure..."
    create_path $ROOT/home/alan/.gnupg
    create_path $ROOT/home/alan/.config
    create_path $ROOT/home/alan/Downloads
    create_path $ROOT/home/alan/Dropbox/Notes
    create_path $ROOT/home/alan/Workspaces
    if [ ! -d $ROOT/tmp ]; then
        mkdir -p $ROOT/tmp && chmod -R 777 $ROOT/tmp
    fi
}

activate_system() {
    echo "Activating mounted NixOS system..."
    chroot $ROOT /nix/var/nix/profiles/system/activate
}

override_resolvconf() {
    echo "Overriding resolv.conf..."
    echo "nameserver 8.8.8.8" > $ROOT/etc/resolv.conf
}

retrieve_dotfiles() {
    echo "Retrieving dotfiles..."
    if [ ! -d /home/alan/.config/dotfiles ]; then
        git clone https://github.com/alanctkc/dotfiles.git /home/alan/.config/dotfiles
        # TODO NIXOS-BRANCH delete following two lines after master merge
        git -C /home/alan/.config/dotfiles fetch origin nixos
        git -C /home/alan/.config/dotfiles checkout nixos
        git -C /home/alan/.config/dotfiles remote rm origin || true
        git -C /home/alan/.config/dotfiles remote add origin git@github.com:alanctkc/dotfiles.git
    fi
}

link_configuration() {
    echo "Linking NixOS configuration..."
    rm -f /etc/nixos/configuration.nix
    ln -sf /home/alan/.config/dotfiles/configuration.nix /etc/nixos/configuration.nix
}

install_dotfiles() {
    echo "Installing dotfiles..."
    cd /home/alan/.config/dotfiles && ./dotme.sh
}

init_emacs() {
    echo "Initializing emacs..."
    # Glorious hack
    emacs --batch --script /home/alan/.emacs.d/init.el 2>&1 | sed -e '/Loading find-lisp.../q'
}

set -e

rebuild_nixos
configure_password
setup_dirs
activate_system
override_resolvconf
export -f retrieve_dotfiles
chroot "$ROOT" /run/wrappers/bin/su alan -c "/run/current-system/sw/bin/bash -c retrieve_dotfiles"
link_configuration
export -f install_dotfiles
chroot "$ROOT" /run/wrappers/bin/su alan -c "/run/current-system/sw/bin/bash -c install_dotfiles"
export -f init_emacs
chroot "$ROOT" /run/wrappers/bin/su alan -c "/run/current-system/sw/bin/bash -c init_emacs"

echo "All done!"
