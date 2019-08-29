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
~$ mkdir -p ~/sksb/isolinux/{images,ks,LiveOS,Packages,postinstall}
```

**Mount CentOS the ISO image**

```
~$ mkdir ~/sksb/iso
~$ cd ~/sksb
sksb $ sudo mount -o loop ~/CentOS-7-x86_64-Minimal-1810.iso ~/sotolito_kickstart_build/iso
```

**Prepare the custom ISO image**
```
sksb $ cp /mnt/iso/.discinfo isolinux/
sksb $ cp ../iso/isolinux/* isolinux/
sksb $ rsync -av ../iso/images/ isolinux/images/
sksb $ cp ../iso/LiveOS/* isolinux/LiveOS/
sksb $ gunzip -c ../iso/repodata/d4de4d1e2d2597c177bb095da8f1ad794d69f76e8ac7ab1ba6340fdd0969e936-c7-minimal-x86_64-comps.xml.gz > comps.xml
sksb $ rsync -av ../iso/Packages/ isolinux/Packages/
sksb $ sudo umount ../iso
sksb $ sudo dnf install -y createrepo
sksb $ cd isolinux/Packages
Packages $ wget http://repos.lax-noc.com/elrepo/archive/kernel/el7/x86_64/RPMS/kernel-ml-5.2.9-1.el7.elrepo.x86_64.rpm
Packages $ wget http://repos.lax-noc.com/elrepo/archive/kernel/el7/x86_64/RPMS/kernel-ml-tools-5.2.9-1.el7.elrepo.x86_64.rpm
Packages $ cd ..
isolinux $ createrepo -g ../comps.xml
```

**Edit and customize the kickstart file**
```
isolinux $ cd ../
sksb $ vim ks.cfg
sksb $ ksvalidator ks.cfg
```

**Update the boot configuration file**

```
sksb $ sed -i 's/CentOS/SotolitoOS/' isolinux/isolinux.cfg
sksb $ sed -i 's/nomodeset quiet/nomodeset quiet ks=cdrom:\/ks\/ks.cfg/' isolinux/isolinux.cfg
```

**Generate the ISO image**

```
sksb $ sudo dnf install -y genisoimage
sksb $ mkisofs -o SotolitoOS-7-custom_dvd.iso -b isolinux.bin -c boot.cat -no-emul-boot -V 'SotolitoOS 7 x86_64' -boot-load-size 4 -boot-info-table -R -J -v -T isolinux/
```




# References
https://devopsmates.com/make-custom-centos-7-rhel-7-cd-kicktart-file/
https://docs.centos.org/en-US/centos/install-guide/Kickstart2/
