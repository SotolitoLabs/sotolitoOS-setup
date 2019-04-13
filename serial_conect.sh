#!/bin/bash

echo "Connecting to Cubietruck plus serial"
screen -t 'Sotolito Serial' /dev/ttyUSB0 115200
