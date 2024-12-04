#!/bin/bash -i

set -e

echo -n "[sudo] password for $USER: "
read -s PASSWORD

echo -ne "\nYour name: "
read NAME
echo -n "Your email: "
read EMAIL

# install base deps
echo $PASSWORD | sudo -S dnf install -y ansible python3-psutil
mkdir -p /tmp/dotfiles

# install chezmoi
if [ ! -f /tmp/dotfiles/chezmoi.tar.gz ] ; then
    wget --no-clobber https://github.com/twpayne/chezmoi/releases/download/v2.10.0/chezmoi_2.10.0_linux_amd64.tar.gz -O /tmp/dotfiles/chezmoi.tar.gz
    (cd /tmp/dotfiles && tar -xzf chezmoi.tar.gz)
fi
mkdir -p $HOME/.local/bin
install /tmp/dotfiles/chezmoi $HOME/.local/bin

# init and apply chezmoi
mkdir -p $HOME/Projects
if [ ! -d $HOME/Projects/dotfiles ] ; then
    git clone git@github.com:alanchrt/dotfiles.git $HOME/Projects/dotfiles
fi
printf "name = \"$NAME\"\nemail = \"$EMAIL\"\n" > $HOME/Projects/dotfiles/.chezmoidata.toml
chezmoi apply --source $HOME/Projects/dotfiles

# install ansible galaxy dependencies
ansible-galaxy collection install community.general
if [ ! -f /tmp/dotfiles/requirements.yml ] ; then
    wget --no-clobber -O /tmp/dotfiles/requirements.yml https://raw.githubusercontent.com/alanchrt/dotfiles/master/requirements.yml
fi
ansible-galaxy install -r /tmp/dotfiles/requirements.yml

# clean up
rm -r /tmp/dotfiles

# run ansible playbook
ANSIBLE_FORCE_COLOR=true ansible-pull --checkout master --url git@github.com:alanchrt/dotfiles.git -i hosts --extra-vars "ansible_sudo_pass=$PASSWORD"

echo "Please restart this machine to make sure all groups, extensions, and services reload properly."
