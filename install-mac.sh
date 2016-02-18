#!/usr/bin/env bash

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git zsh byobu emacs ranger
git clone https://github.com/creationix/nvm.git $HOME/.nvm && cd $HOME/.nvm && git checkout `git describe --abbrev=0 --tags`
source $HOME/.nvm/nvm.sh
npm install -g tern
sudo easy_install pip
sudo pip install virtualenvwrapper flake8 ipython
sudo chpass -s /bin/zsh $USER 
