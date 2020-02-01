# Raspberry Pi 4B 64 Bits
## Distribution Setup
Currently there's no CentOS version of aarm64 for the Raspberry pi so we have to base our kernel and boot files from the ArchLinux Raspberry pi distribution.
We could just use the ArchLinux distro but we want to use CentOS. Right? ;)

**Download ArchLinuxARM-rpi-4-latest.tar.gz**
```
$ wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-4-latest.tar.gz
$ mkdir ArchLinuxArm
$ tar -zxvf ../ArchLinuxARM-rpi-4-latest.tar.gz -C ArchLinuxArm
```

**Prepare the image for creating the rootfs**
The Cloud image starts the cloud-init process so it needs to be disabled.

```
$ mkdir qcow
$ wget https://cloud.centos.org/centos/8/aarch64/images/CentOS-8-GenericCloud-8.1.1911-20200113.3.aarch64.qcow2
$ qemu-img resize CentOS-8-GenericCloud-8.1.1911-20200113.3.aarch64.qcow2 +3G
$ virt-customize -a CentOS-8-GenericCloud-8.1.1911-20200113.3.aarch64.qcow2 --root-password password:rootpw
$ guestfish <<_EOF_
add CentOS-8-GenericCloud-8.1.1911-20200113.3.aarch64.qcow2
run
mount /dev/sda2 /
touch /etc/cloud/cloud-init.disabled
_EOF_
```

**Genrate the rootfs from the CentOS repos**
Login as root with the password already provided.

```
$ DISPLAY=:0 virt-install --name Centos-8-aarch-Test2 --ram 1024 --disk path=CentOS-8-GenericCloud-8.1.1911-20200113.3.aarch64.qcow2 --vcpus 1 --os-type linux --os-variant generic --arch aarch64 --import
# mkdir rootfs
# dnf --releasever=8 --enablerepo=BaseOS --installroot="$(pwd)/rootfs" groups install 'Minimal Install' 2>&1| tee dnf-rootfs.log
```




# Raspberry Pi 3B+

## Installation
Download Fedora or CentOS, in this example we use Fedora 64 bit because the 64 bit CentOS image is not ready yet.

```
sudo fedora-arm-image-installer --image=/home/sotolito/Descargas/Fedora-Minimal-30-1.2.aarch64.raw.xz --media=/dev/sda --selinux=OFF --norootpass -y --resizefs --target=rpi3
```

## Wifi

TODO


## References
https://nullr0ute.com/2018/04/the-raspberry-pi-3-b-in-fedora/

https://www.reddit.com/r/Fedora/comments/91tv1f/how_to_create_a_centos_rootfs/

https://www.raspberrypi.org/documentation/hardware/raspberrypi/bootmodes/bootflow_2711.md
