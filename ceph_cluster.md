# Configure and Install Ceph in SotolitoOs

Sotolito OS uses Ceph as its storage cluster

## Node Requirements

**Create a partition for Ceph OSD**

*We'll use ceph-deploy for the administration tasks.*

**Install the Ceph repo**

*This should be done on all nodes*

The ceph manual recommends this step but there are no builds for armv7l so we'll use the ones from the Fedora repo.

```
# cat << EOM > /etc/yum.repos.d/ceph.repo
[ceph-noarch]
name=Ceph noarch packages
baseurl=https://download.ceph.com/rpm-mimic/el7/noarch
enabled=1
gpgcheck=1
type=rpm-md
gpgkey=https://download.ceph.com/keys/release.asc
EOM
```
**Create Sotolito storage user**

*On each node*

```
# groupadd sotolito-storage-user
# useradd -d /home/sotolito-storage-user -m sotolito-storage-user -g sotolito-storage-user
# echo "sotolito-storage-user ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/sotolito-storage-user
# sudo chmod 0440 /etc/sudoers.d/sotolito-storage-user
```

*On the master node*

```
# su - sotolito-storage-user -c ssh-keygen
# su - sotolito-storage-user
$ ssh-copy-id sotolito-storage-user@sotolito-master
$ ssh-copy-id sotolito-storage-user@sotolito-node1
$ ssh-copy-id sotolito-storage-user@sotolito-node2
```

**Install ceph-deploy**

```
# su - sotolito-storage-user
$ git clone https://github.com/SotolitoLabs/ceph-deploy
$ cd ceph-deply
$ ./bootstrap
$ export PATH=/home/sotolito-storage-user/ceph-deploy/virtualenv/bin/:$PATH
```

*In case the latest ceph-deploy does not get installed install it manually*

```
# dnf install -y python3-ceph-argparse
# rpm -Uvh --nodeps //download.ceph.com/rpm-mimic/el7/noarch/ceph-deploy-2.0.1-0.noarch.rpm
# rpm -Uvh https://mirrors.nju.edu.cn/ceph/rpm-mimic/el7/noarch/ceph-release-1-1.el7.noarch.rpm #in case 
```


**Install suppor packages**

```
# dnf install -y  ntp ntpdate ntp-doc openssh-server
```

**Open Ports**

*On master node*

```
# firewall-cmd --zone=FedoraServer --add-service=ceph-mon --permanent
# firewall-cmd --zone=FedoraServer --add-service=ceph --permanent
# firewall-cmd --reload
```

*On nodes*

```
# firewall-cmd --zone=FedoraServer --add-service=ceph --permanent
# firewall-cmd --reload
```

*On manger node*

```
# firewall-cmd --zone=FedoraServer --add-port=6800-7300/tcp --permanent;  firewall-cmd --reload
# firewall-cmd --reload
```


## Create the cluster

This tasks should be executed as the sotolito-storage-user

```
$ ceph-deploy new sotolito-master
$ echo "public network = 10.253.0.0/24"  >> ceph.conf
$ ceph-deploy install --no-adjust-repos sotolito-master sotolito-node1 sotolito-node2
$ ceph-deploy mon create-initial
$ ceph-deploy admin sotolito-master sotolito-node1 sotolito-node2
$ ceph-deploy mgr create sotolito-node1
$ ceph-deploy osd create --data /dev/sda4 sotolito-master
$ ceph-deploy osd create --data /dev/sda4 sotolito-node1
$ ceph-deploy osd create --data /dev/sda4 sotolito-node2
$ sudo systemctl start ceph-mon@cloud
$ sudo systemctl start ceph-radosgw@cloud

```

Check health

```
$ sudo ceph health
```







# References

* http://docs.ceph.com/docs/mimic/start/

