# .bash_aliases - Alan Christopher Thomas
# http://alanct.com/

# ls aliases
alias ls='ls -G --color=auto'
alias ll='ls -al --color=auto'
alias la='ls -A --color=auto'

# Git aliases
alias gst='git status'
alias gad='git add'
alias gbr='git branch'
alias gcm='git commit'
alias gdi='git diff --color'
alias gdt='git difftool'
alias gco='git checkout'
alias glo='git log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %C(cyan)(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
alias gp="gist -p"

# Editor
alias se='sudoedit'

# Python
alias py='python'
alias ipy='ipython'

# Ranger
alias rn='ranger'

# Virtualenv shortcuts
alias mkve='mkvirtualenv'
alias wo='workon'

# Virtualenv bash completion
if type complete > /dev/null 2>&1; then
    complete -o default -o nospace -F _virtualenvs wo
fi

# Tree colorization
alias tree='tree -C'

# Start tmux session for coding
function to {
    if (( $# == 1 ))
        then
            tmux new-session -s $1
        elif (( $# == 0 ))
            then
                to $(basename $(pwd))
        else
            echo "to takes only one argument: to [sessionname]"
    fi
}

# Start a recorded pairing session
function pair {
    filename=ttyrec-pairing-`date +%Y-%m-%d-%H%M%S`
    read -q "REPLY?Save a recording of this session? [y/N] "
    if [[ "$REPLY" =~ ^[yY]$ ]]
    then
        ttyrec -e tmate $filename
        echo "\nSession finished. Recording saved to $filename."
    else
        tmate
        echo "\nSession finished."
    fi
}

# Remotely add authorized ssh key
function rkey {
    if (( "$#" == 1 ))
        then
            ssh $1 'mkdir -p ~/.ssh && echo '`cat ~/.ssh/id_rsa.pub`' >> ~/.ssh/authorized_keys'
    else
        echo "rkey takes one argument: rkey [user]@[host]"
    fi
}
