## Moximo Configuration Notes

Configuration assumes using Fedora 23 minimal, so many of the features may be already available if any other superior edition is used instead

### Install required packages

```
dnf group install "Development Tools" -y
dnf install parted -y
dnf install librepo --releasever=23 -y
```


### Change hostname

`hostnamectl set-hostname moximo`

After this step is completed you have to restart the system

`shutdown -r now`

### Create local user moximo

`useradd moximo`

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

`dnf install docker cookpit`
