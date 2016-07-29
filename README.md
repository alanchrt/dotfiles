**IMPORTANT:** This is my new, "batteries-included" dotfiles repo, using spacemacs, byobu, and oh-my-zsh. If you're looking for the Vim+tmux+git dotfiles repo that previously lived at this address or has been mentioned in talks, you can now find it [here](https://github.com/alanctkc/dotfiles-old).

## Try it out

This repo includes a Vagrant configuration that automatically provisions the entire setup. Make sure you have [Vagrant, VirtualBox, and Ansible installed](#install-dependencies) first.

Then, clone the repo and create the Vagrant. You'll be prompted for a display name and email address for your git config the first time. This part will take a while.

```bash
$ git clone https://github.com/alanctkc/dotfiles.git
$ cd dotfiles
$ vagrant up
```

SSH into the Vagrant. You'll find the home directory of your host machine at `/host`:

```bash
$ vagrant ssh
$ ls /host
```

Switch to the directory of a project in your home directory and open a tmux session:

```bash
$ cd /host/path/to/projectname
$ to
```

Inside the tmux session, open a file with Spacemacs (the first load will take a while):

```bash
$ e path/to/file.ext
```

Check out some basic Spacemacs keybindings in the [Spacemacs documentation](http://spacemacs.org/doc/DOCUMENTATION.html#orgheadline180).

Detach from your tmux session with `Ctrl+a d`. Reattach using the project directory's name:

```bash
$ ta projectname
```

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

For Vagrant-provisioned dev environments, your host machine home directory will be available inside the VM at `/host`. You can confugre which directory will be synced to `/host` by setting `DEV_VM_SYNCED_FOLDER` on your host machine before running `vagrant up`.

### Running against localhost

It's also possible to provision your local machine with the Ansible playbook:

```bash
$ ansible-playbook -i 'localhost,' -c local playbook.yml
```

### Credentials

There are a few logins that might be worth setting up right off the bat.

##### AWS

```bash
$ aws configure
````

##### Heroku

```bash
$ heroku login
```

##### Gist

```bash
$ gist-paste --login
```

##### Ngrok

```bash
$ ngrok authtoken <token>
```
