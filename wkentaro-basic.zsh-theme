# vim: set ft=zsh:

autoload -U colors && colors

autoload -Uz vcs_info

autoload -U add-zsh-hook

setopt prompt_subst

zstyle ':vcs_info:*' stagedstr '%F{green}+'
zstyle ':vcs_info:*' unstagedstr '%F{222}*'  # yellow
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{11}%r'  # red, yellow
zstyle ':vcs_info:*' enable git svn hg bzr

prompt_precmd () {
  if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
    zstyle ':vcs_info:*' formats '%F{magenta}%}(%b%c%u%B%%F{magenta})'  # magenta
  } else {
    zstyle ':vcs_info:*' formats '%F{magenta}(%b%c%u%B%F{red}…%F{magenta})'  # magenta, red
  }
  vcs_info
}
add-zsh-hook precmd prompt_precmd

collapsed_cwd () {
  local cwd ds length shorten is_changed
  cwd=$(pwd | sed -e "s,^$HOME,~,")
  ds=$(echo $cwd | tr '/' ' ')
  is_changed=0
  length=${#${=ds}}
  shorten=${${=ds}[-$length,-1]}
  while [ $length -gt 1 -a ${#shorten} -gt 46 ]; do
    is_changed=1
    length=$(( $length - 1 ))
    shorten=${${=ds}[-$length,-1]}
  done
  if [ $is_changed -eq 1 ]; then
    if [ "${${=ds}[1]}" = "~" ]; then
      echo '~/…/'$(echo $shorten | tr ' ' '/')
    else
      echo '/…/'$(echo $shorten | tr ' ' '/')
    fi
  else
    echo $cwd
  fi
}

PROMPT='%(!.%{$fg[red]%}.%{$fg[green]%}%n@)%m%{$reset_color%}:%{$fg_bold[blue]%}$(collapsed_cwd)%{$fg_bold[magenta]%}${vcs_info_msg_0_}%{$reset_color%} %# '
