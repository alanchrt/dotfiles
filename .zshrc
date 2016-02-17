# Enable SSH forwarding
zstyle :omz:plugins:ssh-agent agent-forwarding on

# Configure oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
ZSH_THEME='robbyrussell'
plugins=(git tmux vagrant ssh-agent brew debian python pip virtualenv virtualenvwrapper django fabric celery nvm npm go heroku postgres redis-cli colored-man-pages colorize)
source $ZSH/oh-my-zsh.sh

# Enable completion
autoload -U compinit
compinit -i
zstyle ':completion:*' menu select
setopt menu_complete

# Enable colors
autoload -U colors && colors
setopt prompt_subst

# History settings
setopt APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_NO_STORE
SAVEHIST=1000
HISTFILE=$HOME/.zhistory

# Emacs bindings
bindkey -e

# Properly set shell
export SHELL=$(which zsh)

# Include shell environment
if [ -f ~/.shenv ]; then
    . ~/.shenv
fi

# Include alias definitions
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Execute .bash_local
if [ -f ~/.bash_local ]; then
    . ~/.bash_local
fi
