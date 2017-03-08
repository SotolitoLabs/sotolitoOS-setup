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



 5  su - moximo
 6  dnf install sfdisk
 7  dnf provides sfdisk
 8  sfdisk
 9  sfdisk -d
10  sfdisk -d /dev/sda
11  fdisk -l
12  visudo
13  
15  dnf install parted
16  parted /dev/sda
17  exit
18  su - moximo
19  fdisk -l
20  exit
21  fdisk /l
22  fdisk -l
23  mount
24  hostnamectl //help
25  hostnamectl --help
26  
27  ip addr show
28  shutdown -r now
29  dnf install docker cockpit
30  uname -a
31  dnf install docker cockpit
32  dnf update
33  dnf clean all
34  dnf update
35  vi /etc/yum.repos.d/fedora.repo
36  echo $RELEASEVER
37  vi /etc/dnf/dnf.conf
38  ping redhat.com
39  dnf update
40  vi /etc/yum.repos.d/fedora.repo
41  dnf update
42  vi /etc/yum.repos.d/fedora.repo
43  dnf update --refresh
44  vi /etc/yum.repos.d/fedora.repo
45  dnf -4 update --refresh
46  clear
47  rpm -qv --verify fedora-repos
48  rpm -q dnf librepo python-librepo
49  
50  history
51  dnf install docker cockpit
52  mount
