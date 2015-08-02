
# If not running interactively, don't do anything!
[[ $- != *i* ]] && return

# Short hostname (like hostname -s) without domain extension
export HOST=${HOSTNAME%%.*}


# add $HOME/bin to path
export PATH=$PATH:$HOME/bin

# enable bash completion in interactive shells
if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi


#
# PS1 PROMPT
#
export PS1="\[\e[0;32m\]\u@\h\[\e[m\] \[\e[1;34m\]\w\[\e[m\]\[\e[1;32m\]\$(__git_ps1) \$\[\e[m\] \[\e[1;37m\]"

#
# HISTORY Settings
#

HISTFILESIZE=100000
HISTSIZE=40000
HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S] "
HISTCONTROL="ignoreboth"
shopt -s histappend
# Possibly slow. Needs to be checked.
export PROMPT_COMMAND="history -a;$PROMPT_COMMAND"
# Recursive globbing
shopt -s globstar
# No cd needed to switch directories
shopt -s autocd
# Wrap lines again if window size changes
shopt -s checkwinsize


#
# USER SETTINGS
#

# Source scripts in $HOME/.bash/
if [ -d $HOME/.zsh ]; then
  for f in $HOME/.bash/*.sh; do
    . "$f"
  done
  unset f
fi

# Source machine depending settings in $HOME/.bash/${HOST} based
# on bash style regex matching of $HOST with folder names.
# Be aware that only the short hostname is used, not a domain etc.

for dir in $HOME/.bash/* ; do
  if [ -d "$dir" ]; then
    if [[ "$HOST" =~ $(basename ${dir}) ]]; then
      for f in $dir/*; do
        . "$f"
      done
    fi
    unset f
  fi
done

#
# VIM
#

# if gvim available use console version of gvim instead
if [[ -x $(which gvim) ]]; then
  alias vim='gvim -v'
fi

if [[ -x $(which vim) ]]
then
  export EDITOR="vim"
  export USE_EDITOR=$EDITOR
  export VISUAL=$EDITOR
fi
export PAGER="less"

# cd $HOME
