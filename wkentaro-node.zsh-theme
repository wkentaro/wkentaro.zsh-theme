# vim: set ft=zsh:

autoload -U colors && colors

autoload -Uz vcs_info

setopt prompt_subst

_newline=$'\n'

zstyle ':vcs_info:*' stagedstr '%F{green}+'
zstyle ':vcs_info:*' unstagedstr '%F{226}*'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{11}%r'
zstyle ':vcs_info:*' enable git svn
theme_precmd () {
  if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
    zstyle ':vcs_info:*' formats '(%b%c%u%B)'
  } else {
    zstyle ':vcs_info:*' formats '(%b%c%u%B%F{red}…%F{magenta})'
  }
  vcs_info
}

export VIRTUAL_ENV_DISABLE_PROMPT=yes
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
  local cwd
  cwd=$(pwd | sed -e "s,^$HOME,~,")
  pushd >/dev/null
  cd ~
  python -c "\
cwd='$cwd'
dirs=cwd.split('/')
length = len(dirs)
while ( length > 2 and
      len('/'.join(dirs[-(length-1):])) > 50 ):
  length -= 1
if len(dirs) > length:
  cwd='/'.join([dirs[0], '…'] + dirs[-(length-1):])
print(cwd)
" 2>&1
  popd >/dev/null
}

PROMPT='╭─%(!.%{$fg[red]%}.%{$fg_bold[white]%}%n@)%m%{$reset_color%} %{$fg_bold[blue]%}%~ %{$fg_bold[magenta]%}${vcs_info_msg_0_}%{$reset_color%} ${_newline}╰─%# '

autoload -U add-zsh-hook
add-zsh-hook precmd  theme_precmd