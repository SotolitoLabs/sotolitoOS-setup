#!/bin/bash

#Don't run if we're inside a screen session as this can cause keystroke problems
if [[ ${STY} != "" ]]; then
    echo "Can't run inside a screen session"
    exit
fi
echo "Connecting to Cubietruck plus serial"

if [[ $(screen -ls | grep serial) != "" ]]; then
    echo "Serial screen already exists, connecting"
    sudo screen -rd serial
fi

sudo screen -S serial -t 'Sotolito Serial' /dev/ttyUSB0 115200
