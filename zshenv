#Add User specific bin folder
#Already done in xinitrc

USERPATH=$HOME/bin
if [ -d "$USERPATH" ] && [[ ":$PATH:" != *":$USERPATH:"* ]]; then
	PATH="${PATH:+"$PATH:"}$USERPATH"
fi

# PYTHON
#python history and auto completion
export PYTHONSTARTUP=$HOME/.pythonrc
USERPYTHONPATH=$HOME/uni/sw/python_packages
if [ -d "$USERPYTHONPATH" ] && [[ ":$PYTHONPATH:" != *":$USERPYTHONPATH:"* ]]; then
	PYTHONPATH="${PYTHONPATH:+"$PYTHONPATH:"}$USERPYTHONPATH"
fi

#Gnome Keyring 
if [ -n "$DESKTOP_SESSION" ];then
    eval $(gnome-keyring-daemon --start --components=ssh)
    export SSH_AUTH_SOCK
fi
