## Moximo Configuration Notes

Configuration assumes using Fedora 23 minimal, so many of the features may be already available if any other superior edition is used instead

### Install required packages

```
dnf group install "Development Tools" -y
dnf install parted -y
dnf install librepo --releasever=23 -y
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

For this task you'd need to use parted or some other partition management tool.
(Out of scope for now)

### Copy root partition from SD Card to hard drive

Reproducible steps:
- Create mounting point
- Mount hard drive's partition
- tar the system's / partition (exclude /mnt)
- untar in hard drive's corresponding partition

### Change boot Configuration

This has to be done in order to command the system to use hard drive's newly copied root partition instead of the one in the SD Card

Edit /boot/extlinux/extlinux.conf and substitute root=UUID for root=/dev/sda2

### Install cloud Tools

`dnf install docker cockpit`


### Install Kubernetes



TODO:  Define where the rpms are going to be retrieved from

Once you have the kubernetes rpms in moximo's home, install all of them and their dependencies by issuing the following command:
i

As of now download the RPMS from :

http://sotolitolabs.com/RPMS/


`dnf install -y /home/moximo/*.rpm`



Copy configuration files from repo, overwrite if needed

```
yes | cp -rf /home/moximo/moximo-setup/etc/etcd/* /etc/etcd/
yes | cp -rf /home/moximo/moximo-setup/etc/kubernetes/* /etc/kubernetes/
yes | cp -rf /home/moximo/moximo-setup/usr/share/cockpit/branding/* /usr/share/cockpit/branding/
```

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
exit 

```

### Copy moximo master service from repo to system

`cp /home/moximo/moximo-master/contrib/systemd/moximo-master.service /usr/lib/systemd/system/`

### Copy moximo-master to /usr/bin

`cp /home/moximo/moximo-master/_output/build/amd64/moximo-master /usr/bin/`


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

### Reboot and test

`shutdown -r now`
