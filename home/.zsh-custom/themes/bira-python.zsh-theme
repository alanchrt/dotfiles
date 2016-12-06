# Modified version of 'bira' for python virtualenv instead of rvm
# Original here: https://github.com/robbyrussell/oh-my-zsh/blob/master/themes/bira.zsh-theme

local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

if [[ $UID -eq 0 ]]; then
    local user_host='%{$terminfo[bold]$fg[red]%}%n@%m%{$reset_color%}'
else
    local user_host='%{$terminfo[bold]$fg[green]%}%n@%m%{$reset_color%}'
fi

local current_dir='%{$terminfo[bold]$fg[blue]%} %~%{$reset_color%}'
local git_branch='$(git_prompt_info)%{$reset_color%}'
local virtual_env='$(virtualenv_prompt_info)'

PROMPT="┌─${user_host} ${current_dir} ${virtual_env} ${git_branch}
└─%B$%b "
RPS1="${return_code}"

ZSH_THEME_VIRTUALENV_PREFIX="%{$fg[magenta]%}("
ZSH_THEME_VIRTUALENV_SUFFIX=")%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"
