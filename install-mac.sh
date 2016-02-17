#!/usr/bin/env bash

/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew install git zsh byobu emacs ranger
sudo easy_install pip
sudo pip install virtualenvwrapper flake8 ipython
sudo chpass -s /bin/zsh $USER 
