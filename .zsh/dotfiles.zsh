
function dotfiles_install {
    for x in $HOME/.dotfiles/* $HOME/.dotfiles/.[!.]* $HOME/.dotfiles/..?*; do
        echo "Symlinking $f to $HOME/.${f##*/}"
        #ln -s "$f" "$HOME/m{f##*/}"
    done
}
