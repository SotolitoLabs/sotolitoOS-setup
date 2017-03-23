#!/bin/bash

echo "Restoring node..."
cp  etc/moximo/scripts/moximo-setup.sh  /etc/moximo/scripts/.
systemctl stop kube-apiserver.service   kube-controller-manager.service kube-proxy.service kube-scheduler.service kubelet.service
systemctl disable kube-apiserver.service   kube-controller-manager.service kube-proxy.service kube-scheduler.service kubelet.service
systemctl stop moximo-master
systemctl disable moximo-master
cd /etc/sysconfig/network-scripts/
cp ifcfg-eth0:0.FIRSTBOOT ifcfg-eth0\:0
rm /etc/moximo/.node
rm /etc/moximo/.master
touch /etc/moximo/.firstboot
ifup eth0:0

echo "Done.."
