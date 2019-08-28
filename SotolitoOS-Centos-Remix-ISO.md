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
~$ gunzip -c ../iso/repodata/d4de4d1e2d2597c177bb095da8f1ad794d69f76e8ac7ab1ba6340fdd0969e936-c7-minimal-x86_64-comps.xml.gz > comps.xml
~$ rsync -av ../iso/Packages/ isolinux/Packages/
~$ sudo umount ../iso
~$ sudo dnf install -y createrepo
~$ cd isolinux 
~$ createrepo -g ../comps.xml
~$ cd ks
```

**Edit and customize the kickstart file**
```
~$ vim ks.cfg
~$ ksvalidator ks.cfg
```

**Update the boot configuration file**

```
~$ sed -i 's/CentOS/SotolitoOS/' ../../isolinux/isolinux.cfg
~$ sed 's/nomodeset quiet/nomodeset quiet ks=cdrom:\/ks\/ks.cfg/' ../../isolinux/isolinux.cfg
```

**Generate the ISO image**

```
~$ sudo dnf install -y genisoimage
~$ cd ../..
~$ mkisofs -o SotolitoOS-7-custom_dvd.iso -b isolinux.bin -c boot.cat -no-emul-boot -V 'SotolitoOS 7 x86_64' -boot-load-size 4 -boot-info-table -R -J -v -T isolinux/
```



# References
https://devopsmates.com/make-custom-centos-7-rhel-7-cd-kicktart-file/
