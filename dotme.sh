#!/usr/bin/env bash

backup_file() {
    test -e $HOME/$1.dotbackup || test -e $HOME/$1 && cp -LR $HOME/$1 $HOME/$1.dotbackup && rm -rf $HOME/$1
    true
}

backup_directory() {
    test -d $HOME/$1.dotbackup || test -d $HOME/$1 && cp -LR $HOME/$1 $HOME/$1.dotbackup && rm -rf $HOME/$1
    true
}

link_file() {
    backup_file $2
    ln -s `pwd`/confs/$1 $HOME/$2
}

link_directory() {
    backup_directory $2
    ln -s `pwd`/confs/$1 $HOME/$2
}

copy_file() {
    backup_file $2
    cp `pwd`/confs/$1 $HOME/$2
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
    if pushd $HOME/.oh-my-zsh; then git pull origin master; popd; else git clone git://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh; fi
}

install_spacemacs() {
    echo "Installing spacemacs..."
    test -e $HOME/.emacs.d/init.el || backup_directory .emacs.d
    if pushd $HOME/.emacs.d; then git pull origin master; popd; else git clone https://github.com/syl20bnr/spacemacs $HOME/.emacs.d; fi
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
    backup_file .gitconfig
    sed -e 's/\[\[GIT_NAME\]\]/'"$GIT_NAME"'/g' -e 's/\[\[GIT_EMAIL\]\]/'"$GIT_EMAIL"'/g' `pwd`/confs/.gitconfig-global > $HOME/.gitconfig
    copy_file .gitignore-global .gitignore
}

configure_emacs() {
    echo "Configuring emacs..."
    link_file .spacemacs .spacemacs
}

configure_tmux() {
    echo "Configuring tmux..."
    link_file .tmux.conf .tmux.conf
}

delete_backups() {
    rm -rf $HOME/.bash_aliases.dotbackup
    rm -rf $HOME/.bash_local.dotbackup
    rm -rf $HOME/.bash_profile.dotbackup
    rm -rf $HOME/.bashrc.dotbackup
    rm -rf $HOME/.gitconfig.dotbackup
    rm -rf $HOME/.gitignore.dotbackup
    rm -rf $HOME/.shenv.dotbackup
#    rm -rf $HOME/.tmux.conf.dotbackup
    rm -rf $HOME/.zshrc.dotbackup
    rm -rf $HOME/.emacs.d.dotbackup
}

set -e

while :
do
    case $1 in
        -h | --help | -\?) echo "See https://github.com/alanctkc/dotfiles/blob/master/README.md"; exit 0; ;;
        --delete-backups) DELETE_BACKUPS=1; shift; ;;
        --) shift; break; ;;
        -*) printf >&2 'WARNING: Unknown option (ignored): %s\n' "$1"; shift; ;;
        *) break; ;;
    esac
done

if [ "$DELETE_BACKUPS" == 1 ]; then
    delete_backups
    echo "Backups deleted."
    exit 0
fi

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
#configure_tmux
configure_emacs

echo "Done."
