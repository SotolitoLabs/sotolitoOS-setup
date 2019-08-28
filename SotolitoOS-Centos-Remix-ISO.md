# SotolitoOS CentOS Remix ISO

The SotolitoOS Enterprise edition is a CentOS derivative.

## Setup Build Environment

**Download centos**

```
~$ wget http://mirrors.usc.edu/pub/linux/distributions/centos/7.6.1810/isos/x86_64/CentOS-7-x86_64-Minimal-1810.iso
```

**Create Build directories**
*TODO explain directories*

```
~$ mkdir -p ~/sotolito_kickstart_build/isolinux/{images,ks,LiveOS,Packages,postinstall}
```

**Mount CentOS the iso image**

```
~$ mkdir ~/sotolito_kickstart_build/iso
~$ cd ~/sotolito_kickstart_build
~$ sudo mount -o loop ~/CentOS-7-x86_64-Minimal-1810.iso ~/sotolito_kickstart_build/iso
~$ cp /mnt/iso/.discinfo isolinux/
~$ cp ../iso/isolinux/* isolinux/
~$ rsync -av ../iso/images/ isolinux/images/
~$ cp ../iso/LiveOS/* isolinux/LiveOS/
~$ 
```

# References
https://devopsmates.com/make-custom-centos-7-rhel-7-cd-kicktart-file/
