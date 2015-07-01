# ~/.bashrc: executed by bash(1) for non-login shells.


HOST=`hostname -s`


# enable bash completion in interactive shells
if [ -f /usr/share/bash-completion/bash_completion ]; then
  . /usr/share/bash-completion/bash_completion
elif [ -f /etc/bash_completion ]; then
  . /etc/bash_completion
fi


#
# PROMPT
#

export PS1="\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] "


#
# HISTORY
#

HISTFILESIZE=40000
HISTSIZE=40000
HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S] "
HISTCONTROL="ignoreboth"

# Recursive globbing
shopt -s globstar
shopt -s autocd
shopt -s checkwinsize

# Source scripts in $HOME/.bash/

if [ -d $HOME/.zsh ]; then
    for f in $HOME/.bash/*.sh; do
        . "$f"
    done
    unset f
fi

# Source machine depending settings in $HOME/.zsh/$HOST/

if [ -d $HOME/.bash/$HOST ]; then
    for f in $HOME/.bash/$HOST/*; do
        . "$f"
    done
    unset f
fi

#
# VIM
#

if [[ -x $(which vim) ]]
then
    export EDITOR="vim"
    export USE_EDITOR=$EDITOR
    export VISUAL=$EDITOR
fi
export PAGER="less"

