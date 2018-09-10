# vim:ts=4:sw=4
# vim:ts=4:sw=4
# Colors in Terminal
if [ $USER = root ]; then
    PS1='\[\033[1;31m\][\u@\h \W]\$\[\033[0m\] '
else
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]\W\[\033[00m\]\[\033[1;32m\]\$\[\033[m\] '
fi

