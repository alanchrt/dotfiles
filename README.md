**IMPORTANT:** This is my new, "batteries-included" dotfiles repo, using spacemacs, byobu, and oh-my-zsh. If you're looking for the Vim+tmux+git dotfiles repo that previously lived at this address or has been mentioned in talks, you can now find it [here](https://github.com/alanctkc/dotfiles-old).

## Install dependencies

First, install necessary binaries on your system, by either reading through the install scripts and installing manually for your machine, or by running the install script:

```bash
$ ./install-ubuntu.sh
```

Or, on OS X:

```bash
$ ./install-mac.sh
```

## Link dotfiles

Next, link up the dotfiles:

```bash
$ ./dotme.sh
```

A backup of each pre-existing dotfile will be saved with the extension `*.dotbackup`. To delete backups, run:

```bash
$ ./dotme.sh --delete-backups
```
