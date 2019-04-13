#!/bin/bash

echo "Connecting to Cubietruck plus serial"
screen -S serial -t 'Sotolito Serial' /dev/ttyUSB0 115200
