# vim: set ft=zsh:

autoload -U colors && colors

autoload -Uz vcs_info

setopt prompt_subst

# _newline=$'\n'

if [ ! -z $USE_ZSH_GIT_PROMPT ]; then
  ZSH_THEME_GIT_PROMPT_PREFIX="("
  ZSH_THEME_GIT_PROMPT_SUFFIX=")"
  ZSH_THEME_GIT_PROMPT_SEPARATOR=""
  ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg_bold[magenta]%}"
  ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[green]%}%{+%G%}"
  ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg[yellow]%}%{!%G%}"
  ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[blue]%}%{*%G%}"
  ZSH_THEME_GIT_PROMPT_BEHIND="%{$fg_bold[cyan]%}%{v%G%}"
  ZSH_THEME_GIT_PROMPT_AHEAD="%{$fg_bold[green]%}%{^%G%}"
  ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[red]%}%{?%G%}"
  ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg_bold[white]%}%{✔%G%}"
  # PROMPT='╭─%(!.%{$fg[red]%}.%{$fg_bold[white]%}%n@)%m%{$reset_color%} %{$fg_bold[blue]%}%~%{$reset_color%} $(git_super_status) ${_newline}╰─%# '
  PROMPT='%(!.%{$fg[red]%}.%{$fg_bold[white]%}%n@)%m%{$reset_color%}:%{$fg_bold[blue]%}%c%{$reset_color%}$(git_super_status) %# '
else
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

  # PROMPT='╭─%(!.%{$fg[red]%}.%{$fg_bold[white]%}%n@)%m%{$reset_color%} %{$fg_bold[blue]%}%~%{$fg_bold[magenta]%} ${vcs_info_msg_0_}%{$reset_color%} ${_newline}╰─%# '
  PROMPT='%(!.%{$fg[red]%}.%{$fg_bold[white]%}%n@)%m%{$reset_color%}:%{$fg_bold[blue]%}%c%{$fg_bold[magenta]%}${vcs_info_msg_0_}%{$reset_color%} %# '

  autoload -U add-zsh-hook
  add-zsh-hook precmd  theme_precmd
fi

RPROMPT='%{$reset_color%}%T'
