#!/bin/bash -i

set -e

echo -n "[sudo] password for $USER: "
read -s PASSWORD

echo -ne "\nYour name: "
read NAME
echo -n "Your email: "
read EMAIL
echo -n "Your rbw (Bitwarden) email: "
read RBW_EMAIL
echo -n "Top bar color override (leave blank for Dracula default, e.g. rgba(20, 20, 30, 0.98)): "
read PANEL_COLOR

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
    git clone https://github.com/alanchrt/dotfiles.git $HOME/Projects/dotfiles
fi
printf "name = \"$NAME\"\nemail = \"$EMAIL\"\nrbw_email = \"$RBW_EMAIL\"\npanel_color = \"$PANEL_COLOR\"\n" > $HOME/Projects/dotfiles/.chezmoidata.toml
chezmoi apply --source $HOME/Projects/dotfiles

# clean up
rm -r /tmp/dotfiles

# run ansible playbook
ANSIBLE_FORCE_COLOR=true ansible-pull -v --checkout master --url https://github.com/alanchrt/dotfiles.git -i hosts --extra-vars "ansible_sudo_pass=$PASSWORD"

echo "Please restart this machine to make sure all groups, extensions, and services reload properly."
