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
KUBELET_TEMPLATE="/etc/kubernetes/kubelet.TEMPLATE"
KUBELET_FILE="/etc/kubernetes/kubelet"
FIRSTBOOT_IP="10.253.0.254"
MASTER="10.253.0.1"
PORT="8081"

if [ -f /etc/moximo/.node ]; then
  echo "Running as node"
  exit
fi

if [ -f /etc/moximo/.master ]; then
  echo "Running as master, master, master of pupets i'm pulling your strings!!"
  docker run -d -p 5000:5000 --restart=always --name registry registry:2
  exit
fi

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
  ifup "${DEVICE}:0"
}

function setup_slave {
  echo "I'm a SLAVE, setting up network configuration"
  get_next_ip
  echo "Setting node ip to: ${NODE_IP}"
  sed s/{{IP}}/$NODE_IP/ $IF_TEMPLATE > $IF_FILE
  hostnamectl set-hostname --static "${NODE_NAME}"
  sed s/{{ID}}/$NODE_IP/ $KUBELET_TEMPLATE > $KUBELET_FILE
  echo "${NODE_IP}    ${NODE_NAME}"  >> /etc/hosts
  echo "Enabling services for slave"
  systemctl enable kubelet.service
  systemctl enable kube-proxy
  systemctl enable cockpit.socket
  echo "Starting services for slave"
  systemctl start kubelet.service
  systemctl start kube-proxy
  systemctl start cockpit
}

function setup_master {
  echo "I'm a MASTER, setting up network configuration"
  cp $MASTER_TEMPLATE $IF_FILE
  echo "10.253.0.2" > $NODES
  start_if
  hostnamectl set-hostname --static "moximo-master"
  systemctl enable moximo-master
  systemctl start moximo-master

  echo "Enabling services for master"
  systemctl enable etcd
  systemctl enable kube-apiserver
  systemctl enable kube-controller-manager
  systemctl enable kube-proxy
  systemctl enable kube-scheduler
  systemctl enable kubelet.service
  systemctl enable cockpit

  echo "Starting services for master"
  systemctl start etcd
  systemctl start kube-apiserver
  systemctl start kube-controller-manager
  systemctl start kube-proxy
  systemctl start kube-scheduler
  systemctl start kubelet.service
  systemctl start cockpit


}

function start_if {
   echo "Starting ${DEVICE}:0"
   ifup "${DEVICE}:0"
}


function get_next_ip {
  NODE_INFO=$(curl --connect-timeout 2 http://${MASTER}:${PORT}/next_ip 2> /dev/null)
  node=(${NODE_INFO//:/ })
  NODE_IP=${node[0]}
  NODE_NAME=${node[1]}
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
  echo "${NODE_IP}" > /etc/moximo/.node
  exit
fi

#If there's no master then i am the masteeer!!
setup_master
setup_normal_boot
echo "10.253.0.1" > /etc/moximo/.master


# falta inicializar el servicio de master
