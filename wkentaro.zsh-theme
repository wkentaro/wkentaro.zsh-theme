# vim: set ft=zsh:

autoload -U colors && colors

autoload -Uz vcs_info

setopt prompt_subst

_newline=$'\n'

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
  PROMPT='%(!.%{$fg[red]%}.%{$fg[green]%}%n@)%m%{$reset_color%}:%{$fg_bold[blue]%}%c%{$reset_color%}$(git_super_status) %# '
else
  zstyle ':vcs_info:*' stagedstr '%F{green}+'
  zstyle ':vcs_info:*' unstagedstr '%F{226}*'
  zstyle ':vcs_info:*' check-for-changes true
  zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{11}%r'
  zstyle ':vcs_info:*' enable git svn
  theme_precmd () {
      if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
          zstyle ':vcs_info:*' formats ' on %F{206}%b%c%u%B'
      } else {
          zstyle ':vcs_info:*' formats ' on %F{206}%b%c%u%B%F{red}…'
      }
      vcs_info
  }

  export VIRTUAL_ENV_DISABLE_PROMPT=yes
  function virtenv_indicator {
      if [ x$VIRTUAL_ENV != x ]; then
          if [[ $VIRTUAL_ENV == *.virtualenvs/* ]]; then
              ENV_NAME=`basename "${VIRTUAL_ENV}"`
          else
              folder=`dirname "${VIRTUAL_ENV}"`
              ENV_NAME=`basename "$folder"`
          fi
          psvar[1]=$ENV_NAME
      else
          psvar[1]=''
      fi
  }
  add-zsh-hook precmd virtenv_indicator

  function ros_indicator() {
    if [ -d "/opt/ros" ]; then
      looking_path=$(pwd)
      found=$(find $looking_path -maxdepth 1 -iname package.xml | wc -l)
      while [ $found -eq 0 ]; do
        looking_path=$(dirname $looking_path)
        [ "$looking_path" = "/" ] && return
        found=$(find $looking_path -maxdepth 1 -iname package.xml | wc -l)
      done
      echo " rosp %F{045}$(basename $looking_path)%{$reset_color%}"
    fi
  }

  # PROMPT='╭─%(!.%{$fg[red]%}.%{$fg_bold[white]%}%n@)%m%{$reset_color%} %{$fg_bold[blue]%}%~%{$fg_bold[magenta]%} ${vcs_info_msg_0_}%{$reset_color%} ${_newline}╰─%# '
  # PROMPT='%(!.%{$fg[red]%}.%{$fg[green]%}%n@)%m%{$reset_color%}:%{$fg_bold[blue]%}%c%{$fg_bold[magenta]%}${vcs_info_msg_0_}%{$reset_color%} %# '
  PROMPT='%F{162}%n%{$reset_color%} at %F{215}%m%{$reset_color%} in %F{156}%5c%{$reset_color%}${vcs_info_msg_0_}%{$reset_color%}%(1V. workon %F{111}%1v%{$reset_color%}.)$(ros_indicator) ${_newline}%# '

  autoload -U add-zsh-hook
  add-zsh-hook precmd  theme_precmd
fi
