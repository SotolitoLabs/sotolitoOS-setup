## Image burning for CubieTruck

The following instructions detail the steps to burn a Sotolito OS image for using with a CubieTruck Plus card

THIS DOC NEEDS A LOT OF LOVE


#### Installation Example






### Get the Sotolito OS image and copy it to the SD card


```
dd if=SotolitoOS-1.28-SD.img of=/dev/sda bs=16M
```




```
sudo fedora-arm-image-installer --image=sotolitoLabs/cubietruck/Fedora-Minimal-armhfp-23-10-sda.raw.xz --target=Cubietruck --media=/dev/sda --selinux=OFF --norootpass -y --resizefs
```

### Install required packages

```
dnf group install "Development Tools" -y
dnf install parted -y
dnf install librepo --releasever=23 -y
dnf install xfsprogs -y
dnf install tar -y
dnf install wget -y
```

Kubernetes >= 1.3 is required, it will be installed ahead

### Change hostname

`hostnamectl set-hostname moximo`

After this step is completed you have to restart the system

`shutdown -r now`

### Create local user moximo

`useradd -c "Moximo Cloud Appliance Admin User" moximo`

### Clone code repo

This has to be performed as user moximo, so change user before cloning

```
su - moximo
git clone https://github.com/SotolitoLabs/moximo-setup.git  
exit
```

### Copy filesystem structure from file to hard drive

`sfdisk /dev/sda < /home/moximo/moximo-setup/sys/hd/sdd.sfdisk`


### Extend hard drive's third partition (var) to maximum space available

For this task you may use parted or some other partition management tool.

If CLI is preferred, then issue the following command

`echo ", +" | sfdisk -N 3 /dev/sda`

### Copy root partition from SD Card to hard drive

In order to accomplish this, we need -first of all- format the hard drive's partitions as follows:

- /dev/sda1 as swap
- /dev/sda2 as xfs
- /dev/sda3 as xfs

```
mkswap /dev/sda1
mkfs.ext4 /dev/sda2
mkfs.xfs /dev/sda3
```

Then we create the directories for the mounting points:

```
mkdir -p /mnt/moximo
mount /dev/sda2 /mnt/moximo

mkdir /mnt/moximo/var
mount /dev/sda3 /mnt/moximo/var
```

Next we tar the root directory, excluding mnt

`tar --exclude=/mnt -c / > /mnt/moximo/var/moximo.tar`

And untar recently created file in /mnt/sda3

```
cd /mnt/moximo/
tar -x ./var/moximo.tar 
```
Modify /etc/fstab

```
/dev/sda1          swap swap      defaults,noatime 0 0
/dev/mmcblk1p2     /boot ext4     defaults,noatime 0 0
/dev/sda2          / xfs          defaults,noatime 0 0
/dev/sda3          /var xfs       defaults,noatime 0 0

```

Finally, unmount mounting points and delete directories in /mnt/

```
cd ~
umount /mnt/moximo/var
umount /mnt/moximo
rm -rf /mnt/*
```


### Change boot Configuration

This has to be done in order to command the system to use hard drive's newly copied root partition instead of the one in the SD Card

Edit /boot/extlinux/extlinux.conf and substitute root=UUID for root=/dev/sda2

Label may be customized as well.

Reboot system so next boot will run root on hard drive

`shutdown -r now`


### Install cloud Tools

`dnf install docker cockpit`


### Install Kubernetes


Download kubernetes client from the following links (temporaly for now):

```
wget http://sotolitolabs.com/moximo/RPMS/kubernetes-client-1.3.0-0.3.rc1.git52492b4.fc26.armv7hl.rpm
wget http://sotolitolabs.com/moximo/RPMS/kubernetes-debuginfo-1.3.0-0.3.rc1.git52492b4.fc26.armv7hl.rpm
wget http://sotolitolabs.com/moximo/RPMS/kubernetes-master-1.3.0-0.3.rc1.git52492b4.fc26.armv7hl.rpm
wget http://sotolitolabs.com/moximo/RPMS/kubernetes-node-1.3.0-0.3.rc1.git52492b4.fc26.armv7hl.rpm
wget http://sotolitolabs.com/moximo/RPMS/kubernetes-unit-test-1.3.0-0.3.rc1.git52492b4.fc26.armv7hl.rpm
wget http://sotolitolabs.com/moximo/RPMS/kubernetes-1.3.0-0.3.rc1.git52492b4.fc26.armv7hl.rpm
```


Once you have the kubernetes rpms in moximo's home, install all of them and their dependencies by issuing the following command:


`dnf install -y /home/moximo/*.rpm`


Copy configuration files from repo, overwrite if needed

```
cp -rf /home/moximo/moximo-setup/etc/etcd/* /etc/etcd/
cp -rf /home/moximo/moximo-setup/etc/kubernetes/* /etc/kubernetes/
cp -rf /home/moximo/moximo-setup/usr/share/cockpit/branding/* /usr/share/cockpit/branding/
```

## Configure kube-proxy 

```
 kube-proxy --write-config-to test
```

## Configure kubelet to master-kubeconfig.yaml

```
kind: Config
clusters:
- name: local
  cluster:
    server: http://10.253.0.1:8080
users:
- name: kubelet
contexts:
- context:
    cluster: local
    user: kubelet
  name: kubelet-context
current-context: kubelet-context
```

## Install Moximo Master service binary

```
curl http://sotolitolabs.com/moximo/dist/arm/moximo-master --output /usr/bin/moximo-master
```

## Install Moximo Master service from source

### Clone moximo-master

Change to moximo user

```
su - moximo
git clone https://github.com/SotolitoLabs/moximo-master.git
exit
```

### Download gorilla/mux go package

```
su - moximo 
mkdir go
export GOPATH=$HOME/go
go get github.com/gorilla/mux
cd moximo-master
make
make install
exit 

```

### Copy moximo master service from repo to system

`cp /home/moximo/moximo-master/contrib/systemd/moximo-master.service /usr/lib/systemd/system/`

### Copy moximo-master to /usr/bin

`cp /home/moximo/moximo-master/_output/build/arm/moximo-master /usr/bin/`


### Copy systemd unit files

`cp /home/moximo/moximo-setup/init/systemd/moximo-setup.service /usr/lib/systemd/system/`


### Enable moximo-setup

`systemctl enable moximo-setup`


### copy moximo scripts

```
mkdir -p /etc/moximo/scripts
cp /home/moximo/moximo-setup/etc/moximo/scripts/moximo-setup.sh /etc/moximo/scripts/
```



### Copy network scripts from repo

`cp /home/moximo/moximo-setup/etc/sysconfig/network-scripts/ifcfg-eth0* /etc/sysconfig/network-scripts/`

### clone moximo cockpit fork

```
su - moximo
git clone https://github.com/SotolitoLabs/cockpit.git
exit
```


### copy cockpit from repo

```
cd /home/moximo/cockpit/
git checkout moximo-0.2.0
cp -R pkg/moximo /usr/share/cockpit/
cp -R pkg/kubernetes /usr/share/cockpit/
```
### Create firstboot environment

```
touch /etc/moximo/.firstboot
```

### Reboot and test

`shutdown -r now`
