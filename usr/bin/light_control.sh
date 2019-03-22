#!/bin/bash

VALUE=0

if [[ $2 == "on" ]]; then
  VALUE=255
fi

if [[ $1 == "all" ]]; then
  for color in "blue" "orange" "green" "white"; do
    echo "Setting ${color} led to ${2}"
    echo $VALUE > /sys/class/leds/cubietruck-plus\:$color\:usr/brightness
  done
else
  echo $VALUE > /sys/class/leds/cubietruck-plus\:$1\:usr/brightness
fi

