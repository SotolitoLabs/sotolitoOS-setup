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

**Download CentOS for aarch64**
We are going to use the generic CentOS aarch64 to create our SotolitoOS aarch64 spin
```
$ wget http://mirror.vcu.edu/pub/gnu_linux/centos/8.1.1911/isos/aarch64/CentOS-8.1.1911-aarch64-boot.iso
```

**Mount the Centos ISO**
```
$ mkdir CentOS-iso
$ sudo mount -o loop CentOS-8.1.1911-aarch64-boot.iso CentOS-iso
```

**x86_64 ONLY**
If you are creating the rootfs from a x86_64 machine you have to download the CentOS cloud image and create it from there:
```
$ mkdir qcow
$ wget https://cloud.centos.org/centos/8/aarch64/images/CentOS-8-GenericCloud-8.1.1911-20200113.3.aarch64.qcow2
$ guestfish <<_EOF_
add CentOS-8-GenericCloud-8.1.1911-20200113.3.aarch64.qcow2
run
mount /dev/sda2 /
touch /etc/cloud/cloud-init.disabled
_EOF_
```

**Genrate the rootfs from the CentOS repos**
```
$ mkdir rootfs
$ sudo dnf --releasever 8 -c repos/centos.repo  --disablerepo=* --enablerepo=centos8-base --installroot="$(pwd)/rootfs" groups install 'Minimal Install' 2>&1| tee dnf-rootfs.log
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
