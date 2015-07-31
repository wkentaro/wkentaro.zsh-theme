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

PROMPT='%(!.%{$fg[red]%}.%{$fg[green]%}%n@)%m%{$reset_color%}:%{$fg_bold[blue]%}%c%{$fg_bold[magenta]%}${vcs_info_msg_0_}%{$reset_color%} %# '

autoload -U add-zsh-hook
add-zsh-hook precmd  theme_precmd
