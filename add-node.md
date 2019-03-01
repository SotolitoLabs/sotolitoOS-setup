# Add Sotolito OS Node

## Set Cluster IP

*Get the DHCP temporary IP and run the ansible playbook for network*
```
[root@moximo-master ansible]# ssh-copy-id 192.168.1.23
[root@moximo-master ansible]#  ansible-playbook -i hosts/compute-initial -e 'node_ip_address=10.253.0.4' playbooks/network.yaml 
```
