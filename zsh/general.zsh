pathadd() {
    if [ -d "$2" ] && [[ ":$(eval \$$1):" != *":$2:"* ]]; then
        PATH="${1:+"$1:"}$2"
        export $1
    fi
}

function mount_uni()
{
    MOUNTDIR=/home/aem/mnt
    if [ ! -d "$MOUNTDIR" ]; then
        mkdir -p $MOUNTDIR
    fi
    sshfs sieber@ekpcms5:/ $MOUNTDIR/ekpcms5
}

function abspath() { echo $(readlink -f "$1") }
