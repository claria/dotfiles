# prompt
function prompt_char() {
if [ $UID -eq 0 ]; then
  echo "#"
else 
  echo $
fi
}

function ppgrep() { 
pgrep "$@" | xargs ps fp; 
}

function cleansvn() {
svn status --no-ignore | grep '^[?I]' |  sed "s/^[?I] //" | xargs -I{} rm -rf "{}"
}

#changing directories
cd () {
  if   [[ "x$*" == "x..." ]]; then
    cd ../..
  elif [[ "x$*" == "x...." ]]; then
    cd ../../..
  elif [[ "x$*" == "x....." ]]; then
    cd ../../../..
  elif [[ "x$*" == "x......" ]]; then
    cd ../../../../..
  elif [ -d ~/.autoenv ]; then
    source ~/.autoenv/activate.sh
    autoenv_cd "$@"
  else
    builtin cd "$@"
  fi
}

publish() {
  TARGET='sieber@ekplx35.physik.uni-karlsruhe.de:public_html/private/dump/'
  for var in "$@"
  do
    scp -r "$var" ${TARGET}
    fname=$(basename $var)
    echo "http://www-ekp.physik.uni-karlsruhe.de/~sieber/private/dump/$fname"
  done
}


# Easy extract
extract () {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2 | *.tbz2) tar xjf $1;;
            *.tar.gz | *.tgz) tar xzf $1;;
            *.bz2) bunzip2 $1;;
            *.gz) gunzip $1;;
            *.rar) rar x $1;;
            *.tar) tar xf $1;;
            *.zip) unzip $1;;
            *.Z) uncompress $1;;
            *) echo "'$1' cannot be extracted via extract()";;
        esac
  else
    echo "'$1' is not a valid file"
  fi
}
