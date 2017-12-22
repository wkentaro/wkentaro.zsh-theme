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
    psvar[1]="venv:$ENV_NAME"
  elif [ x$CONDA_DEFAULT_ENV != x ]; then
    prefix=$(echo $CONDA_PREFIX | sed -e "s,^$HOME,~,")
    psvar[1]="conda:$CONDA_DEFAULT_ENV ($prefix)"
  else
    psvar[1]=""
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
    pkg_name=$(grep '<name>' $looking_path/package.xml | sed -e 's,.*<name>\(.*\)</name>,\1,g')
    echo " rosp %F{045}$(basename $pkg_name)%{$reset_color%}"
  fi
}
_show_rosenv () {
  if [ "$ROS_MASTER_URI" = "" ]; then
    return
  fi
  if [[ ! $ROS_MASTER_URI =~ "http://localhost.*" ]]; then
    echo "%F{red}[$ROS_MASTER_URI][$ROS_IP]%{$reset_color%} "
  fi
}

collapsed_cwd () {
  local cwd ds length shorten is_changed
  cwd=$(pwd | sed -e "s,^$HOME,~,")
  ds=$(echo $cwd | tr '/' ' ')
  is_changed=0
  length=${#${=ds}}
  shorten=${${=ds}[-$length,-1]}
  while [ $length -gt 1 -a ${#shorten} -gt ${COLUMNS} ]; do
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

_ssh_connection_color () {
  if [ "$SSH_CONNECTION" = "" ]; then
    echo "%F{215}"
  else
    echo "%F{171}"
  fi
}

prompt_left1='$(_show_rosenv)%F{005}%n%{$reset_color%} at $(_ssh_connection_color)%m%{$reset_color%}'
# prompt_left2=' in %F{156}$(collapsed_cwd)%{$reset_color%} tm %F{purple}$(date +'%a %b %d %H:%M')%{$reset_color%}'
prompt_left2=' in %F{156}$(collapsed_cwd)%{$reset_color%} tm %F{147}$(date +"%H:%M")%{$reset_color%}'
prompt_left3='${vcs_info_msg_0_}%{$reset_color%}%(1V. workon %F{111}%1v%{$reset_color%}.)$(ros_indicator) ${_newline}%(?,%F{green},%F{red})%#%{$reset_color%} '

update_prompt () {
  local prompt_left1_len=$(count_prompt_chars "$prompt_left1")
  local prompt_left2_len=$(count_prompt_chars "$prompt_left2")
  local prompt_left3_len=$(count_prompt_chars "$prompt_left3")
  local prompt_left_rest=$[COLUMNS - prompt_left1_len]
  if [ $prompt_left_rest -gt $prompt_left2_len ]; then
    prompt_left_rest=$[prompt_left_rest - prompt_left2_len]
    if [ $prompt_left_rest -gt $prompt_left3_len ]; then
      PROMPT="$prompt_left1$prompt_left2$prompt_left3"
    else
      PROMPT="$prompt_left1$prompt_left2${_newline}…$prompt_left3"
    fi
  else
    prompt_left_rest=$[COLUMNS - prompt_left2_len]
    if [ $prompt_left_rest -gt $prompt_left3_len ]; then
      PROMPT="$prompt_left1${_newline}…$prompt_left2$prompt_left3"
    else
      PROMPT="$prompt_left1${_newline}…$prompt_left2${_newline}…$prompt_left3"
    fi
  fi
}

precmd_functions=($precmd_functions update_prompt)
