#!/bin/bash

echo "Creating ceph-storage user"
groupadd sotolito-storage-user
useradd -d /home/sotolito-storage-user -m sotolito-storage-user -g sotolito-storage-user
echo "sotolito-storage-user ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/sotolito-storage-user
sudo chmod 0440 /etc/sudoers.d/sotolito-storage-user
su - sotolito-storage-user -c ssh-keygen
ssh-copy-id sotolito-storage-user@sotolito-master
ssh-copy-id sotolito-storage-user@sotolito-node1
ssh-copy-id sotolito-storage-user@sotolito-node2
