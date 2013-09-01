# Skip all this for non-interactive shells
[[ -z "$PS1" ]] && return
#” Lines configured by zsh-newuser-install
bindkey -e

source .zsh/functions.zsh


#Enable 256 colors support for gnome-terminal/xterm etc
if [ -n "$DISPLAY" -a "$TERM" '==' "xterm" ]; then
    export TERM=xterm-256color
fi

#
# Auto Completion
#

autoload -Uz compinit
compinit


# move cursor to the end of the word on completion 
setopt ALWAYS_TO_END
setopt noautomenu
# expand expression as if it were preceded by a `~' on cd
#setopt CDABLE_VARS
# list choices on an ambiguous completion
setopt AUTO_LIST

# If the parameter content is a directory, add a trailing slash
setopt AUTO_PARAM_SLASH



#
# KEYMAP
#

typeset -A key

key[Home]=${terminfo[khome]}

key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}

# setup key accordingly
[[ -n "${key[Home]}"    ]]  && bindkey  "${key[Home]}"    beginning-of-line
[[ -n "${key[End]}"     ]]  && bindkey  "${key[End]}"     end-of-line
[[ -n "${key[Insert]}"  ]]  && bindkey  "${key[Insert]}"  overwrite-mode
[[ -n "${key[Delete]}"  ]]  && bindkey  "${key[Delete]}"  delete-char
[[ -n "${key[Up]}"      ]]  && bindkey  "${key[Up]}"      up-line-or-history
[[ -n "${key[Down]}"    ]]  && bindkey  "${key[Down]}"    down-line-or-history
[[ -n "${key[Left]}"    ]]  && bindkey  "${key[Left]}"    backward-char
[[ -n "${key[Right]}"   ]]  && bindkey  "${key[Right]}"   forward-char

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    function zle-line-init () {
        printf '%s' "${terminfo[smkx]}"
    }
    function zle-line-finish () {
        printf '%s' "${terminfo[rmkx]}"
    }
    zle -N zle-line-init
    zle -N zle-line-finish
fi

autoload -U colors && colors

#
# PROMPT
#


PROMPT="%{$fg[blue]%}%n%{$reset_color%}@%{$fg[green]%}%m %{$fg_no_bold[yellow]%}%~ %{$reset_color%}%#"
RPROMPT="[%{$fg_no_bold[yellow]%}%?%{$reset_color%}]"

chpwd() {
  [[ -t 1 ]] || return
  case $TERM in
    sun-cmd) print -Pn "\e]l%~\e\\"
      ;;
    *xterm*|rxvt|(dt|k|E)term) print -Pn "\e]2;%~\a"
      ;;
  esac
}





# Set less options
if [[ -x $(which less) ]]
then
    export PAGER="less"
    export LESS="--ignore-case --LONG-PROMPT --QUIET --chop-long-lines -Sm --RAW-CONTROL-CHARS --quit-if-one-screen --no-init"
    export LESSHISTFILE='-'
    if [[ -x $(which lesspipe.sh) ]]
    then
    LESSOPEN="| lesspipe.sh %s"
    export LESSOPEN
    fi
fi

# Set default editor
if [[ -x $(which vim) ]]
then
    export EDITOR="vim"
    export USE_EDITOR=$EDITOR
    export VISUAL=$EDITOR
fi

# 
# HISTORY
#

export HISTSIZE=25000
export HISTFILE=~/.zsh_history
export SAVEHIST=10000
setopt APPEND_HISTORY
#setopt SHARE_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

# Colors

autoload -U colors && colors
# Enable color support of ls
if [[ "$TERM" != "dumb" ]]; then
    if [[ -x `which dircolors` ]]; then
	eval `dircolors -b`
	alias 'ls=ls --color=auto'
    fi
fi


# Say how long a command took, if it took more than 30 seconds
export REPORTTIME=30


bindkey ';5D' backward-word
bindkey ';5C' forward-word



# Background processes aren't killed on exit of shell
#setopt AUTO_CONTINUE

# Don’t write over existing files with >, use >! instead
setopt NOCLOBBER

# Don’t nice background processes
setopt NO_BG_NICE

# Watch other user login/out
watch=notme
export LOGCHECK=60

##############
# ALIAS
##############

#alias vim='gvim -v'
alias nano='nano -w'
alias hist='history | grep $1'
alias df='df -h'
alias du='du -c -h'
alias rm='rm -I'
alias ls='ls --color=auto'
function ppgrep() { pgrep "$@" | xargs ps fp; }
#Todo.txt
alias todo=~/.todotxt/todo.sh
#Evo
alias evo="javaws 'http://evo.caltech.edu/evoNext/koala.jnlp'"
#Mensa
alias mensa="w3m -dump 'http://mensa.akk.org/?DATUM=heute&uni=1' | sed -n '/Linie/,/Stand/p'"
alias monuni='xrandr --output LVDS1 --auto --output VGA1 --auto --right-of LVDS1'
#Vidyo
alias vidyo='PULSE_LATENCY_MSEC=30 /opt/vidyo/VidyoDesktop/VidyoDesktop'
#Pycharm
alias pycharm='wmname LG3D && /opt/pycharm/bin/pycharm.sh'
