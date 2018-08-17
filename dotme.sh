#!/usr/bin/env bash

link_file() {
    if [ ! -z "$HOME" ] && [ ! -z "$2" ]; then
        rm -f $HOME/$2
    fi
    ln -s `pwd`/home/$1 $HOME/$2
}

link_directory() {
    if [ ! -z "$HOME" ] && [ ! -z "$2" ]; then
        rm -rf $HOME/$2
    fi
    ln -s `pwd`/home/$1 $HOME/$2
}

clone_or_pull_repo() {
    if [ ! -f $HOME/$2/README.md ]; then
        git clone https://github.com/$1.git $HOME/$2
    else
        pushd $HOME/$2 > /dev/null
        git pull
        popd > /dev/null
    fi
}

install_oh_my_zsh() {
    echo "Installing oh-my-zsh..."
    mkdir -p $HOME/.zsh-custom/plugins
    clone_or_pull_repo robbyrussell/oh-my-zsh .oh-my-zsh
    clone_or_pull_repo zsh-users/zsh-syntax-highlighting .zsh-custom/plugins/zsh-syntax-highlighting
}

install_spacemacs() {
    echo "Installing spacemacs..."
    clone_or_pull_repo syl20bnr/spacemacs .emacs.d
}

configure_shell() {
    echo "Configuring common shell environment..."
    mkdir -p $HOME/.local/share
    link_file .bash_aliases .bash_aliases
    link_file .shenv .shenv
    link_file .local/share/highlight.el .local/share/highlight.el
}

configure_bash() {
    echo "Configuring bash..."
    link_file .bash_profile .bash_profile
    link_file .bashrc .bashrc
}

configure_zsh() {
    echo "Configuring zsh..."
    link_file .zshrc .zshrc
    link_directory .zsh-custom .zsh-custom
    rm -f $HOME/.zcompdump
}

configure_termite() {
    echo "Configuring termite..."
    mkdir -p $HOME/.config/termite
    link_file .config/termite/config .config/termite/config
    link_file .config/termite/drop_config .config/termite/drop_config
}

configure_kitty() {
    echo "Configuring kitty..."
    mkdir -p $HOME/.config/kitty
    link_file .config/kitty/kitty.conf .config/kitty/kitty.conf
}

configure_byobu() {
    echo "Configuring byobu..."
    mkdir -p $HOME/.byobu
    link_file .byobu/.tmux.conf .byobu/.tmux.conf
    link_file .byobu/status .byobu/status
}

configure_ranger() {
    echo "Configuring ranger..."
    mkdir -p $HOME/.config/ranger
    link_file .config/ranger/scope.sh .config/ranger/scope.sh
    link_file .config/ranger/rc.conf .config/ranger/rc.conf
}

configure_git() {
    echo "Configuring git..."
    link_file .gitconfig-global .gitconfig
    link_file .gitignore-global .gitignore
}

configure_emacs() {
    echo "Configuring emacs..."
    link_file .spacemacs .spacemacs
}

configure_python() {
    echo "Configuring python..."
    mkdir -p $HOME/.config
    link_file .config/flake8 .config/flake8
}

configure_node() {
    echo "Configuring node.js..."
    link_file .jsbeautifyrc .jsbeautifyrc
}

configure_i3() {
    echo "Configuring i3..."
    mkdir -p $HOME/.config
    mkdir -p $HOME/.config/dunst
    link_directory .config/i3 .config/i3
    link_file .config/compton.conf .config/compton.conf
    link_file .config/dunst/dunstrc .config/dunst/dunstrc
    link_file .Xresources .Xresources
}

configure_gtk() {
    echo "Configuring GTK..."
    link_file .gtkrc-2.0 .gtkrc-2.0
    link_directory .config/gtk-3.0 .config/gtk-3.0
}

configure_qt() {
    echo "Configuring Qt..."
    link_file .config/Trolltech.conf .config/Trolltech.conf
}

configure_default_apps() {
    echo "Configuring default applications..."
    link_file .config/mimeapps.list .config/mimeapps.list
    link_file .config/user-dirs.dirs .config/user-dirs.dirs
}

set -e

install_oh_my_zsh
install_spacemacs
configure_shell
configure_bash
configure_zsh
configure_termite
configure_kitty
configure_byobu
configure_ranger
configure_git
configure_emacs
configure_python
configure_node
configure_i3
configure_gtk
configure_qt
configure_default_apps

touch $HOME/.dotted
echo "Done."
