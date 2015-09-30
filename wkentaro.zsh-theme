# vim: set ft=zsh:

autoload -U colors && colors

autoload -Uz vcs_info

autoload -U add-zsh-hook

setopt prompt_subst
setopt transient_rprompt

_newline=$'\n'

zstyle ':vcs_info:*' stagedstr '%F{green}+'
zstyle ':vcs_info:*' unstagedstr '%F{222}*'  # yellow
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{11}%r'  # red, yellow
zstyle ':vcs_info:*' enable git svn hg bzr

_git_is_dirty () {
  local dirty=0
  [ $(git status --porcelain 2>/dev/null | grep '^??' | wc -l) -eq 0 ] || dirty=1
  return $dirty
}

prompt_precmd () {
  if _git_is_dirty; then
    zstyle ':vcs_info:*' formats ' on %F{206}%b%c%u%B'  # magenta
  else
    zstyle ':vcs_info:*' formats ' on %F{206}%b%c%u%B%F{red}…'  # magenta, red
  fi
  vcs_info
}
add-zsh-hook precmd prompt_precmd

virtenv_indicator () {
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
VIRTUAL_ENV_DISABLE_PROMPT=yes
add-zsh-hook precmd virtenv_indicator

ros_indicator () {
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

count_prompt_chars() {
  print -n -P -- "$1" | sed -e $'s/\e\[[0-9;]*m//g' | wc -m | sed -e 's/ //g'
}

prompt_left1='%F{162}%n%{$reset_color%} at %F{215}%m%{$reset_color%} in %F{156}$(collapsed_cwd)%{$reset_color%}'
prompt_left2='${vcs_info_msg_0_}%{$reset_color%}%(1V. workon %F{111}%1v%{$reset_color%}.)$(ros_indicator) ${_newline}%(?,%F{green},%F{red})%#%{$reset_color%} '
RPROMPT='%{%B%}%D{%Y/%m/%d %H:%M}%{%b%}'

update_prompt () {
  local prompt_left1_len=$(count_prompt_chars "$prompt_left1")
  local prompt_left2_len=$(count_prompt_chars "$prompt_left2")
  local prompt_left_rest=$[COLUMNS - prompt_left1_len]
  if [ $prompt_left_rest -gt $prompt_left2_len ]; then
    PROMPT="$prompt_left1$prompt_left2"
  else
    PROMPT="$prompt_left1${_newline}$prompt_left2"
  fi
}

precmd_functions=($precmd_functions update_prompt)
