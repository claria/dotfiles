#!/bin/zsh

PATH=$HOME/bin:$PATH

#completion
autoload -U compinit
compinit

# correction
setopt correctall

#colors
autoload -U colors
colors

#vcs_info
autoload -Uz vcs_info

# Source scripts in $HOME/.zsh/

if [ -d $HOME/.zsh ]; then
    for f in $HOME/.zsh/*.zsh; do
        . "$f"
    done
    unset f
fi

# Source machine depending settings in $HOME/.zsh/$HOST/

if [ -d $HOME/.zsh/$HOST ]; then
    for f in $HOME/.zsh/$HOST/*; do
        . "$f"
    done
    unset f
fi

#
# Prompt
#

setopt PROMPT_SUBST
zstyle ':vcs_info:*' actionformats \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{3}|%F{1}%a%F{5}]%f '
zstyle ':vcs_info:*' formats       \
    '%F{5}(%f%s%F{5})%F{3}-%F{5}[%F{2}%b%F{5}]%f '
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '%b%F{1}:%F{3}%r'
zstyle ':vcs_info:*' enable git svn
precmd() {
    vcs_info
}

PROMPT='%(!.%{$fg_bold[red]%}.%{$fg_bold[green]%}%n@)%m %{$fg_bold[blue]%}%(!.%1~.%~) ${vcs_info_msg_0_}%_$(prompt_char)%{$reset_color%} '

#
# VIM
#

# setopt vi

if [[ -x $(which vim) ]]
then
    export EDITOR="vim"
    export USE_EDITOR=$EDITOR
    export VISUAL=$EDITOR
fi
export PAGER="less"

#
# ZSH Options
#

unsetopt correct_all
setopt ALWAYS_TO_END
setopt no_auto_menu
setopt AUTO_LIST
setopt AUTO_CD
setopt EXTENDED_GLOB          # globs #, ~ and ^
# If we have a glob this will expand it
setopt GLOB_COMPLETE
setopt PUSHD_MINUS
# If I could disable Ctrl-s completely I would!
setopt NO_FLOW_CONTROL

#
# History settings
#

export HISTSIZE=25000
export SAVEHIST=$HISTSIZE
export HISTFILE=$HOME/.zsh_history
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
export REPORTTIME=30

#
# CDing
#

setopt auto_pushd
setopt pushd_ignore_dups
setopt pushdminus
