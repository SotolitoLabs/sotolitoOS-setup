#!/bin/bash

LOCAL_IP=$(ip addr show eth0 | grep -Po 'inet \K[\d.]+')
ACTION="Started"

if [[ $1 != "start" ]]; then
  ACTION="Stopped"
fi

res=$(curl -XGET "http://sotolitolabs.com/monitoring/control.php?local_ip=${LOCAL_IP}&action=${ACTION}")

echo "RES: ${res}"
