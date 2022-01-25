## Overview

This is my Fedora, GNOME, Spacemacs, byobu, and oh-my-zsh setup, tailored toward mnemonic vim-like keybindings, tools with smart defaults that Just Work&trade;, and an integrated desktop and development experience.

Here are some references for getting around the system:

- **[GNOME configuration](roles/gnome/tasks/main.yml) -** Desktop keybindings
- **[Spacemacs documentation](http://develop.spacemacs.org/doc/DOCUMENTATION.html) -** IDE experience
- **[Byobu man page](http://manpages.ubuntu.com/manpages/zesty/en/man1/byobu.1.html#contenttoc8) -** Tmux keybindings
- **[Shell aliases](home/dot_bash_aliases) -** Terminal aliases for zsh and bash

## Installation

You may prefer to test out this setup in a virtual machine (on [VirtualBox](https://www.virtualbox.org/) or friends) before committing to an install on your host machine.

### Set up the base system

1. Download [the latest Fedora Workstation ISO](https://getfedora.org/en/workstation/download/).
2. Create bootable media for your machine or attach as bootable storage to a fresh VM.
3. Boot into the image and complete the graphical installer.

### Bootstrap this configuration

The following command will configure the base software on Fedora and copy dotfiles from this repo for your user. Make sure you have an SSH key for this machine configured on GitHub (bootstrap will clone this repo over SSH).

```shell
wget -qO- https://raw.githubusercontent.com/alanchrt/dotfiles/master/bootstrap.sh | bash
```
