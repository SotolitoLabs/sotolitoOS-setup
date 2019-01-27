# Configure and Install Ceph in SotolitoOs

Sotolito OS uses Ceph as its storage cluster

## Node Requirements

**Create a partition for Ceph OSD**

*We'll use ceph-deploy for the administration tasks.*

**Install the Ceph repo**

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




# References

* http://docs.ceph.com/docs/mimic/start/

