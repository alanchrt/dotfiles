#!/usr/bin/env bash

link_file() {
    rm $HOME/$2
    ln -s `pwd`/home/$1 $HOME/$2
}

link_directory() {
    rm -r $HOME/$2
    ln -s `pwd`/home/$1 $HOME/$2
}

copy_file() {
    cp `pwd`/home/$1 $HOME/$2
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
    clone_or_pull_repo robbyrussell/oh-my-zsh .oh-my-zsh
}

install_spacemacs() {
    echo "Installing spacemacs..."
    clone_or_pull_repo syl20nbr/spacemacs .emacs.d
}

configure_shell() {
    echo "Configuring common shell environment..."
    link_file .bash_aliases .bash_aliases
    link_file .shenv .shenv
    if [ "$OSTYPE" == "darwin"* ]; then
        copy_file .bash_local-mac .bash_local
    else
        copy_file .bash_local-linux .bash_local
    fi
}

configure_bash() {
    echo "Configuring bash..."
    link_file .bash_profile .bash_profile
    link_file .bashrc .bashrc
}

configure_zsh() {
    echo "Configuring zsh..."
    link_file .zshrc .zshrc
    rm -f $HOME/.zcompdump
}

configure_git() {
    echo "Configuring git..."
    sed -e 's/\[\[GIT_NAME\]\]/'"$GIT_NAME"'/g' -e 's/\[\[GIT_EMAIL\]\]/'"$GIT_EMAIL"'/g' `pwd`/home/.gitconfig-global > $HOME/.gitconfig
    copy_file .gitignore-global .gitignore
}

configure_emacs() {
    echo "Configuring emacs..."
    link_file .spacemacs .spacemacs
}

set -e

if [ -z "$GIT_NAME" ]; then
    read -p "Git user.name: " GIT_NAME
fi

if [ -z "$GIT_EMAIL" ]; then
    read -p "Git user.email: " GIT_EMAIL
fi

install_oh_my_zsh
install_spacemacs
configure_shell
configure_bash
configure_zsh
configure_git
configure_emacs

echo "Done."
