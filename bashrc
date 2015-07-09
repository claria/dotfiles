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


# export PS1="\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] "
export PS1="\[\e[0;32m\]\u@\h\[\e[m\] \[\e[1;34m\]\w\[\e[m\]\[\e[1;32m\]\$(__git_ps1) \$\[\e[m\] \[\e[1;37m\]"
#
# HISTORY
#

HISTFILESIZE=100000
HISTSIZE=10000
HISTTIMEFORMAT="[%Y-%m-%d %H:%M:%S] "
HISTCONTROL="ignoreboth"
shopt -s histappend

# Recursive globbing
shopt -s globstar
shopt -s autocd
shopt -s checkwinsize

# Source scripts in $HOME/.bash/

if [ -d $HOME/.bash ]; then
    for f in $HOME/.bash/*.sh; do
        . "$f"
    done
    unset f
fi

# Source machine depending settings in $HOME/.bash/ based
# on regex matching of $HOST with folder name.

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

if [[ -x $(which vim) ]]
then
    export EDITOR="vim"
    export USE_EDITOR=$EDITOR
    export VISUAL=$EDITOR
fi
export PAGER="less"

eval $(/usr/bin/gnome-keyring-daemon --start --components=pkcs11,secrets,ssh)
export SSH_AUTH_SOCK


cd $HOME
