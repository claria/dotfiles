# dotfiles


Repository of my private dotfiles. The structure of the dotfiles repository
resembles the structure of the dotfiles in the home directory, but without trailing
dots. You can have a hosts folder with additional dotfiles for a specific machine whill
will only be installed on that machine. The folder structure could look like
the following:

```
.dotfiles
│   dotman.py
│   README.md
└───.git
│
│   dotfile1
│   dotfile2
└───folder1
│   └───dotfile3
│   └───dotfile4
└───hosts
    └───machine1
    │   └───dotfile1
    └───machine2
        └───dotfile5
```

By default dotman.py ignores the .git, hosts, README.md and dotman.py and creates symbolic 
links for all other files in the home directory. You can install all symlinks using the command

'dotman.py install'

If you want to add an existing file in your home directory to your .dotfiles repository use
the command

'dotman.py add /path/to/.dotfile1 /path/to/.dotfile2'





