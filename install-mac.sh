#!/usr/bin/env bash

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git zsh byobu ranger
brew tap railwaycat/homebrew-emacsmacport
brew install emacs-mac --with-spacemacs-icon
brew linkapps
git clone https://github.com/creationix/nvm.git $HOME/.nvm && cd $HOME/.nvm && git checkout `git describe --abbrev=0 --tags`
source $HOME/.nvm/nvm.sh
npm install -g tern
sudo easy_install pip
sudo pip install virtualenvwrapper flake8 ipython autoflake yapf
sudo chpass -s /bin/zsh $USER
