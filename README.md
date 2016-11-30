## Overview

This is my Arch Linux, Firefox/Vimperator, Byobu, Oh-my-zsh, and Spacemacs setup, tailored toward mnemonic vim-like keybindings, tools with smart defaults that Just Work&trade;, and an integrated desktop and development experience.

The system requires [Manjaro Linux](https://manjaro.org/) (specifically [Manjaro i3](https://sourceforge.net/projects/manjaro-i3/files/)) as a base, then uses Ansible to provision additional software and configuration on top.

Here are some references for getting around the system:

- **[Ansible roles](playbooks/roles) -** Software and configuration
- **[i3 config](home/.config/i3/config) -** Desktop keybindings
- **[Spacemacs documentation](http://spacemacs.org/doc/DOCUMENTATION.html) -** Development experience
- **[Byobu man page](http://manpages.ubuntu.com/manpages/zesty/en/man1/byobu.1.html#contenttoc8) -** Tmux keybindings
- **Vimperator Help -** Discoverable by installing Vimperator Firefox extension and typing `:help<Return>`
- **[Bash aliases](home/.bash_aliases) -** Terminal aliases for zsh and bash

## Installation

You may prefer to test out this setup in a virtual machine (on [VirtualBox](https://www.virtualbox.org/) or friends) before committing to an install on your host machine.

### Base system setup

1. Download [the latest Manjaro i3 ISO](https://sourceforge.net/projects/manjaro-i3/files/).
2. Create bootable media for your machine or attach as bootable storage to a fresh VM.
3. Boot into the image and use Calamares to complete the Manjaro i3 installation.

### Dotfiles installation

1. Install Ansible and Git:

    ```
    $ sudo pacman -S ansible git
    ```

2. Clone this repo:

    ```
    $ git clone https://github.com/alanctkc/dotfiles.git ~/.config/dotfiles
    ```

3. Run the Ansible playbook:

    ```
    $ cd ~/.config/dotfiles
    $ ./provision-local.sh
    ```

### Credentials

There are a few logins that might be worth setting up right off the bat if needed.

##### AWS

```
$ aws configure
```

##### Heroku

```
$ heroku login
```

##### Gist

```
$ gist --login
```

##### Ngrok

```
$ ngrok authtoken <token>
```

##### Google Cloud Print

```
$ sudo /usr/share/cloudprint-cups/setupcloudprint.py
```
