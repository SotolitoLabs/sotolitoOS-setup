# vim:ts=4:sw=4
# vim:ts=4:sw=4
# Colors in Terminal
if [ $USER = root ]; then
    PS1="\[\033[33m\][\[\033[m\]\[\033[31m\]\u@\h\[\033[m\] \[\033[33m\]\W\[\033[m\]\[\033[33m\]]\[\033[m\] # "
else
    PS1='\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]\W\[\033[00m\]\[\033[1;32m\]\$\[\033[m\] '
fi

