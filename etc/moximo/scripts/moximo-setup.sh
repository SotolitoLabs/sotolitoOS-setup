#!/bin/bash

# moximo_setup.sh
# Iván Chavero <ichavero@chavero.com.mx>
# Setup the moximo box as master or node
# this script is for Red Hat distros

DEVICE="eth0"
NODES="/etc/moximo/nodes"
IF_FILE="/etc/sysconfig/network-scripts/ifcfg-eth0:0"
MASTER_TEMPLATE="/etc/sysconfig/network-scripts/ifcfg-eth0:0.MASTER"
IF_TEMPLATE="/etc/sysconfig/network-scripts/ifcfg-eth0:0.TEMPLATE"
FIRSTBOOT_IP="10.253.0.254"
MASTER="10.253.0.1"
PORT="8081"

# If there's the first time it boots it uses the last IP in
# the segment

function setup_firstboot {
  echo "First boot, yeehaaaaa!!"
  # we come preconfigured with this IP
  #ip addr add $FIRSTBOOT_IP/24 dev $DEVICE label "${DEVICE}:0"
}

function setup_normal_boot {
  rm /etc/moximo/.firstboot
  ip addr del $FIRSTBOOT_IP/24 dev "${DEVICE}:0"
}

function setup_slave {
  echo "I'm a SLAVE, setting up network configuration"
  get_next_ip
  sed s/{{IP}}/$NEXT_IP/ $IF_TEMPLATE > $IF_FILE
  setup_normal_boot
  hostnamectl set-hostname --static "${NODE_NAME}"
}

function setup_master {
  echo "I'm a MASTER, setting up network configuration"
  cp $MASTER_TEMPLATE $IF_FILE
  echo "10.253.0.2" > $NODES
  start_if
  hostnamectl set-hostname --static "moximo-master"
  systemctl start moximo-master
}

function start_if {
   echo "Starting ${DEVICE}:0"
   ifup "${DEVICE}:0"
}


function get_next_ip {
  CURR_IP=$(curl --connect-timeout 2 http://${MASTER}:${PORT}/next_ip 2> /dev/null)
  LAST=$(echo $CURR_IP |  cut -d"." -f4)
  NODE_NAME=$LAST
}

if [[ -e /etc/moximo/.firstboot ]]; then
	setup_firstboot
fi

# check if there's a master

echo "Checking for if a master is available"
IS_MASTER=$(curl --connect-timeout 2 http://${MASTER}:${PORT} 2> /dev/null)

if [[ ${IS_MASTER} == "IM_THE_CHOSEN_ONE" ]]; then
  echo "This is the master node yeeeei!!"
  exit
fi

if [[ ${IS_MASTER} == "MASTER_OK" ]]; then
  setup_slave
  setup_normal_boot
  exit
fi

#If there's no master then i am the masteeer!!
setup_master
setup_normal_boot


# falta inicializar el servicio de master
