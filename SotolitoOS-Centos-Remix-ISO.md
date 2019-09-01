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

## Prepare the custom ISO image

**Prepare the filesystem**
```
sksb $ cp /mnt/iso/.discinfo isolinux/
sksb $ cp ../iso/isolinux/* isolinux/
sksb $ rsync -av ../iso/images/ isolinux/images/
sksb $ cp ../iso/LiveOS/* isolinux/LiveOS/
```

**Add the SotolitoOS core group**

```
cat << EOF > sotolito-core.xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE comps PUBLIC "-//Red Hat, Inc.//DTD Comps info//EN" "comps.dtd">
<comps>
        
  <group>
   <id>sotolito-core</id>
   <default>false</default>
   <uservisible>true</uservisible>
   <display_order>1024</display_order>
   <name>Sotolito Core</name>
   <description></description>
    <packagelist>
      <packagereq type="mandatory">ansible</packagereq>
      <packagereq type="mandatory">cockpit</packagereq>
      <packagereq type="mandatory">git</packagereq>
      <packagereq type="mandatory">podman</packagereq>
      <packagereq type="mandatory">skopeo</packagereq>
    </packagelist>
  </group>
</comps>
EOF
```

**Download CentOS packages**
Instead of having a centos instance and copying the packages to the ISO repository 
or looking for the package and it's depencies URL's we use dnf to download the 
package and dependencies.

```
podman run --rm -ti --name=tmp-centos-dnf -v /absolute_path_to/isolinux/Packages/:/var/preserve \
  registry.centos.org/centos/centos  yum install --downloadonly --downloaddir=/var/preserve \
  cockpit git ansible skopeo podman
```
**NOTE:** We need to copy the CentOS repo files from a live system or download them from the internet,
but this still beats having to manage the package files manually.

**Prepare iso repository**
```
sksb $ gunzip -c ../iso/repodata/d4de4d1e2d2597c177bb095da8f1ad794d69f76e8ac7ab1ba6340fdd0969e936-c7-minimal-x86_64-comps.xml.gz > comps.xml
sksb $ rsync -av ../iso/Packages/ isolinux/Packages/
sksb $ sudo umount ../iso
sksb $ sudo dnf install -y createrepo

sksb $ cd isolinux/Packages
Packages $ wget http://repos.lax-noc.com/elrepo/archive/kernel/el7/x86_64/RPMS/kernel-ml-5.2.9-1.el7.elrepo.x86_64.rpm
Packages $ wget http://repos.lax-noc.com/elrepo/archive/kernel/el7/x86_64/RPMS/kernel-ml-tools-5.2.9-1.el7.elrepo.x86_64.rpm
Packages $ cd ..
isolinux $ createrepo -g ../comps.xml -g ../sotolito-core.xml
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
sksb $ mkisofs -o SotolitoOS-7-custom.iso -b isolinux.bin -c boot.cat -no-emul-boot -V 'SotolitoOS 7 x86_64' -boot-load-size 4 -boot-info-table -R -J -v -T isolinux/
sksb $ isohybrid SotolitoOS-7-custom.iso
```




# References
https://devopsmates.com/make-custom-centos-7-rhel-7-cd-kicktart-file/

https://docs.centos.org/en-US/centos/install-guide/Kickstart2/

TODO: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html-single/anaconda_customization_guide/index

