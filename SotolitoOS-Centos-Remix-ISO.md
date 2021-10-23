# SotolitoOS CentOS Remix ISO

The SotolitoOS Enterprise edition is a CentOS derivative.

## Lorax Composer

Lorax Composer is a tool for creatin CentOS remixes.

## Prepare Builder VM

```
[root@centos8 ~]# dnf install -y yum-utils createrepo httpd lorax-composer
[root@centos8 ~]# setenforce 0
[root@centos8 ~]# systemctl enable httpd
[root@centos8 ~]# systemctl start httpd
```
https://docs.centos.org/en-US/centos/install-guide/Composer/

## Manual

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

**Brand the installer**
Anaconda has a very easy way to brand your installation process. It lets you
duplicate the instller filesystem in an image file called product.img.
This image is copied to a directory called `images` in the root of the installer.

```
sksb $ mkdir -p product/usr/share/anaconda/pixmaps/rnotes/en/
sksb $ mkdir -p product/run/install/product/pyanaconda/installclasses
sksb $ cp ../../files/images/branding/sotolitoLabs_original_white_distro.png product/usr/share/anaconda/pixmaps/sidebar-logo.png 
sksb $ cat cat << EOF > .buildstamp
[Main]
Product=SotolitoLabs Enterprise Linux
Version=7.4
BugURL=https://bugzilla.redhat.com/
IsFinal=True
UUID=201909020004.x86_64
[Compose]
Lorax=19.6.92-1
EOF
```

Also lets you override stuff using *custom installation* classes.

```
sksb $ cat cat << EOF > product/run/install/product/pyanaconda/installclasses/custom.py
from pyanaconda.installclass import BaseInstallClass
from pyanaconda.product import productName
from pyanaconda import network
from pyanaconda import nm

class CustomBaseInstallClass(BaseInstallClass):
    name = "SotolitoOS"
    sortPriority = 30000
    if not productName.startswith("SotolitoOS"):
        hidden = True
    defaultFS = "xfs"
    bootloaderTimeoutDefault = 5
    bootloaderExtraArgs = []

    ignoredPackages = ["ntfsprogs"]

    installUpdates = False

    _l10n_domain = "comps"

    efi_dir = "sotolitoOS"

    help_placeholder = "SotolitoOS.html"
    help_placeholder_with_links = "SotolitoOSWithLinks.html"

    def configure(self, anaconda):
        BaseInstallClass.configure(self, anaconda)
        BaseInstallClass.setDefaultPartitioning(self, anaconda.storage)

    def setNetworkOnbootDefault(self, ksdata):
        if ksdata.method.method not in ("url", "nfs"):
            return
        if network.has_some_wired_autoconnect_device():
            return
        dev = network.default_route_device()
        if not dev:
            return
        if nm.nm_device_type_is_wifi(dev):
            return
        network.update_onboot_value(dev, "yes", ksdata)

    def __init__(self):
        BaseInstallClass.__init__(self)
EOF
```

**Generate the product.img file**

```
sksb $ cd product
product $ find . | cpio -c -o | gzip -9cv > ../isolinux/images/product.img

```


**Generate the ISO image**

```
sksb $ sudo dnf install -y genisoimage
sksb $ mkisofs -o SotolitoOS-7-custom.iso -b isolinux.bin -c boot.cat -no-emul-boot -V 'SotolitoOS 7 x86_64' -boot-load-size 4 -boot-info-table -R -J -v -T isolinux/
sksb $ isohybrid SotolitoOS-7-custom.iso
```

## Brand the squashfs

**Centos 8 based**

```

sksb $ cd ../files
files $ mkdir tmp-squashfs
files $ cd tmp-squashfs
tmp-squashfs $ unsquashfs ../../scripts/sotolito-iso/iso/images/install.img
tmp-squashfs $ mkdir mnt
tmp-squashfs $ sudo mount  squashfs-root/LiveOS/rootfs.img -o loop mnt
tmp-squashfs $ sudo sed -i 's/CentOS/SotolitoOS/' mnt/etc/os-release
tmp-squashfs $ sudo umount mnt
tmp-squashfs $ cd ..
tmp-squashfs $ mksquashfs squashfs-root squashfs-sotolito-stream.img -comp xz

```


**Centos 7 based**
In order for the installer to show the proper brand while booting we need to modify the squashfs.img from the CentOS base ISO.

```
 sksb $ cd
 ~$ mkdir sotol-squash; cd sotol-squash
 sotol-squash $
 sotol-squash $ cp ../sotolito-iso/isolinux/LiveOS/squashfs.img .
 sotol-squash $ unsquashfs squashfs.img
 sotol-squash $ cd squashfs-root/LiveOS/
 sotol-squash $ mkdir tmp
 sotol-squash $ sudo mount -o loop rootfs.img tmp
 sotol-squash $ sudo sed -i 's/CentOS/SotolitoOS/' tmp/etc/os-release
 sotol-squash $ sudo umount tmp
 sotol-squash $ cd ..
 sotol-squash $ mksquashfs squashfs-root squashfs-sotolito.img -comp xz
 sotol-squash $ cp squashfs-sotolito.img ../../sotolito-iso/isolinux/LiveOS/squashfs.img
```




# TODO

* Create a sotolitoos-release package based on: centos-release-7-6.1810.2.el7.centos.x86_64.rpm 
  to preserve branding.


# References
https://devopsmates.com/make-custom-centos-7-rhel-7-cd-kicktart-file/

https://docs.centos.org/en-US/centos/install-guide/Kickstart2/

TODO: https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html-single/anaconda_customization_guide/index

https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html-single/anaconda_customization_guide/index#sect-product-img
