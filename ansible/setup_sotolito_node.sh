#!/bin/bash

# Sotlito setup node
# <ichavero@chavero.com.mx>
# This is GPLv2 you know where to look for it

DHCP_IP=$2

ansible-playbook -vvvv -u root -i /etc/ansible/sotolito/hosts/common \
  /etc/ansible/sotolito/playbooks/add-node.yaml  -e "node_ip_address=$DHCP_IP" \
  -e "ansible_ssh_private_key_file=/etc/dhcp/scripts/.ssh/sotolito_id_rsa"

