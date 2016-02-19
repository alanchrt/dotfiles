#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install -y python-pip python-dev build-essential zsh git byobu emacs24 ranger
git clone https://github.com/creationix/nvm.git $HOME/.nvm && cd $HOME/.nvm && git checkout `git describe --abbrev=0 --tags`
source $HOME/.nvm/nvm.sh
npm install -g tern
sudo pip install virtualenvwrapper flake8 ipython autoflake yapf
sudo chsh $USER -s /bin/zsh
