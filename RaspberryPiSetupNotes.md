# Raspberry Pi 4B 64 Bits
## Distribution Setup
Currently there's no CentOS version of aarm64 for the Raspberry pi so we have to base our kernel and boot files from the ArchLinux Raspberry pi distribution.
We could just use the ArchLinux distro but we want to use CentOS. Right? ;)

**Download ArchLinuxARM-rpi-4-latest.tar.gz**
```
$ wget http://os.archlinuxarm.org/os/ArchLinuxARM-rpi-4-latest.tar.gz
$ mkdir ArchLinuxArm
$ tar -zxvf ArchLinuxARM-rpi-4-latest.tar.gz -C ArchLinuxArm
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
$ DISPLAY=:0 virt-install --name Centos-8-aarch-Rootfs --ram 1024 --disk path=CentOS-8-GenericCloud-8.1.1911-20200113.3.aarch64.qcow2 --vcpus 1 --os-type linux --os-variant generic --arch aarch64 --import
# mkdir rootfs
# dnf --releasever=8 --enablerepo=BaseOS --installroot="$(pwd)/rootfs" groups install 'Minimal Install' 2>&1| tee dnf-rootfs.log
# tar -zc rootfs > centos-8-rootfs.tar.gz
```

**Copy the rootfs to the host**
Copy the centos-8-rootfs.tar.gz from the host

```
$ virt-copy-out -d Centos-8-aarch-Rootfs /root/centos-8-rootfs.tar.gz .
```

**Create partitions on the SD Card**
Use fdisk, sfdisk or cfdisk to create this partition schema:

```
Device         Boot   Start     End Sectors  Size Id Type
/dev/mmcblk0p1         2048 1026047 1024000  500M  c W95 FAT32 (LBA)
/dev/mmcblk0p2      1026048 5220351 4194304    2G 83 Linux
```

Format the partitions: `boot` as vfat and `/` xfs

```
$ sudo mkfs.fat -F32 /dev/mmcblk0p1
$ sudo mkfs.xfs /dev/mmcblk0p2
```

**Copy the Arch distribution boot directory to the boot partition**
```
$ sudo mount /dev/mmcblk0p1 /mnt
$ cd ArchLinuxARM-rpi-4-latest/boot/
$ tar -zc * > ../../arch-rpi4-boot.tar.gz
$ cd ../..
$ sudo tar -zxvf arch-rpi4-boot.tar.gz -C /mnt 
$ sudo umount /mnt
```

**Untar the rootfs in the SD card root partition**

```
$ sudo mount /dev/mmcblk0p2 /mnt
$ cd ..
$ sudo tar -zxvf centos-8-rootfs.tar.gz -C /mnt --strip 1
```

**Create the fstab file**
```
# cat <<EOF>> /mnt/etc/fstab
/dev/mmcblk0p2  /       xfs     defaults        1       1
/dev/mmcblk0p1  /boot   vfat    defaults        0       0
EOF
```


**Copy the modules and firmware directories to the rootfs**
From the Arch distribution copy the /lib/modules and /lib/firmware to the SD card

```
$ cd ArchLinuxARM-rpi-4-latest
$ tar -c lib/modules lib/firmware > ../archlinux-modules-firmware.tar
$ cd ..
$ sudo tar -xf archlinux-modules-firmware.tar -C /mnt
```

**Test installation**
Unmount the SD card and test it in the Raspberry Pi 4

## Kernel building

If cross compiling, install the development tools needed for the kernel

```
$ sudo dnf install -y gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu
```

**Clone the kernel tree**
```
$ git clone --depth=1 https://github.com/raspberrypi/linux
```

**Build the kernel**

```
$ cd linux
$ KERNEL=kernel7l ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- make bcm2711_defconfig
$ KERNEL=kernel7l ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- make -j7 Image modules dtbs
$ sudo mount /dev/mmcblk0p2 /mnt
$ sudo mount /dev/mmcblk0p1 /mnt/boot/
$ sudo KERNEL=kernel7l ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- INSTALL_MOD_PATH=/mnt make modules_install
$ sudo cp arch/arm64/boot/Image /mnt/boot/kernel8.img
$ sudo cp arch/arm/boot/dts/* /mnt/boot/
$ sudo cp -v Module.symvers System.map /mnt/boot/
$ sudo cp arch/arm/boot/dts/overlays/* /mnt/boot/overlays/
# cat <<EOF>> /mnt/boot/config.txt
gpu_mem=64
arm_64bit=1
EOF
```

*The arm_64bit option has to be set no zero for the board to boot in 64 bit mode*




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

https://www.raspberrypi.org/documentation/linux/kernel/building.md

https://github.com/sakaki-/gentoo-on-rpi-64bit/wiki/Build-an-RPi3-64bit-Kernel-on-your-crossdev-PC

https://www.raspberrypi.org/documentation/configuration/config-txt/boot.md
