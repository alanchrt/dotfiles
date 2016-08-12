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

# Bind history substring search
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# Properly set shell
export SHELL=$(which zsh)

# Include shell environment
if [ -f ~/.shenv ]; then
    . ~/.shenv
fi

# Enable SSH forwarding
zstyle :omz:plugins:ssh-agent agent-forwarding on

# Configure oh-my-zsh
export ZSH=$HOME/.oh-my-zsh
ZSH_CUSTOM=~/.zsh-custom
ZSH_THEME='bira-python'
DISABLE_VENV_CD=1
plugins=(tmux vagrant ssh-agent python pip virtualenv virtualenvwrapper django fabric celery nvm npm heroku redis-cli colored-man-pages colorize history-substring-search safe-paste)
source $ZSH/oh-my-zsh.sh

# Redefine tmux wrapper to use byobu-tmux
function _zsh_tmux_plugin_run()
{
    # We have other arguments, just run them
    if [[ -n "$@" ]]
    then
        \byobu-tmux $@
        # Try to connect to an existing session.
    elif [[ "$ZSH_TMUX_AUTOCONNECT" == "true" ]]
    then
        \byobu-tmux `[[ "$ZSH_TMUX_ITERM2" == "true" ]] && echo '-CC '` attach || \byobu-tmux `[[ "$ZSH_TMUX_ITERM2" == "true" ]] && echo '-CC '` `[[ "$ZSH_TMUX_FIXTERM" == "true" ]] && echo '-f '$_ZSH_TMUX_FIXED_CONFIG` new-session
        [[ "$ZSH_TMUX_AUTOQUIT" == "true" ]] && exit
        # Just run tmux, fixing the TERM variable if requested.
    else
        \byobu-tmux `[[ "$ZSH_TMUX_ITERM2" == "true" ]] && echo '-CC '` `[[ "$ZSH_TMUX_FIXTERM" == "true" ]] && echo '-f '$_ZSH_TMUX_FIXED_CONFIG`
        [[ "$ZSH_TMUX_AUTOQUIT" == "true" ]] && exit
    fi
}

# Include alias definitions
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Execute .bash_local
if [ -f ~/.bash_local ]; then
    . ~/.bash_local
fi
