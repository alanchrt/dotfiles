**IMPORTANT:** This is my new, "batteries-included" dotfiles repo, using spacemacs, byobu, and oh-my-zsh. If you're looking for the Vim+tmux+git dotfiles repo that previously lived at this address or has been mentioned in talks, you can now find it [here](https://github.com/alanctkc/dotfiles-old).

## Link dotfiles

The repo contains a simple bootstrap script to link up dotfiles into your home directory (requires git):

```bash
$ ./dotme.sh
```

## Install dependencies

Examine [this Ansible playbook](playbook.yml) to see the software I typically provision on new development machines.

You can run this playbook against your own hosts or, alternatively, run the development environment in an Ubuntu VM on your own system using Vagrant.

#### Ubuntu

```bash
$ sudo apt-get install vagrant virtualbox ansible
$ vagrant up
```

#### Mac OS X

```bash
$ brew cask install vagrant virtualbox
$ brew install ansible
$ vagrant up
```

### Running against localhost

It's also possible to provision your local machine with the Ansible playbook:

```bash
$ ansible-playbook -i 'localhost,' -c local playbook.yml
```
