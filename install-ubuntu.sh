#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install -y python-pip python-dev build-essential zsh git byobu ranger

git clone https://github.com/creationix/nvm.git $HOME/.nvm && cd $HOME/.nvm && git checkout `git describe --abbrev=0 --tags`
source $HOME/.nvm/nvm.sh
npm install -g tern

sudo pip install virtualenvwrapper flake8 ipython autoflake yapf

sudo chsh $USER -s /bin/zsh

pushd /usr/local/src
sudo wget http://mirror.team-cymru.org/gnu/emacs/emacs-24.4.tar.gz
sudo tar xvf emacs-24.4.tar.gz
sudo apt-get build-dep emacs24
pushd emacs-24.4
./configure
make
sudo make install
popd && popd
