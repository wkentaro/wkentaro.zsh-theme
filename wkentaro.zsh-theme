# vim: set ft=zsh:
autoload -U colors && colors

autoload -Uz vcs_info

zstyle ':vcs_info:*' stagedstr '%F{green}+'
zstyle ':vcs_info:*' unstagedstr '%F{yellow}*'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{11}%r'
zstyle ':vcs_info:*' enable git svn
theme_precmd () {
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
        zstyle ':vcs_info:*' formats '(%b%c%u%B%F{magenta})'
    } else {
        zstyle ':vcs_info:*' formats '(%b%c%u%B%F{red}…%F{magenta})'
    }
    vcs_info
}

setopt prompt_subst

_newline=$'\n'
PROMPT='╭─%(!.%{$fg[red]%}.%{$fg_bold[white]%}%n@)%m%{$reset_color%} %{$fg_bold[blue]%}%~%{$fg_bold[magenta]%} ${vcs_info_msg_0_}%{$reset_color%} ${_newline}╰─%# '
RPROMPT='%{$reset_color%}%T'

autoload -U add-zsh-hook
add-zsh-hook precmd  theme_precmd
