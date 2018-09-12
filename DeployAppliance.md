## Sotolito OS Appliance deployment

Steps for deploying sotolito OS

### Write Base image to SD Card

Get the image 

```
curl http://sotolitolabs.com/files/sotolitoos/latest/sd/SotolitoOS-1.28-SD.img > SotolitoOS-1.28-SD.img
```

```
dd if=SotolitoOS-1.28-SD.img of=/dev/mmcblk0 bs=16M
```

### Boot the board

The first time we boot the Sotolito OS image we have to perform some setup
tasks for the sytem to be prepared for production.


### Create Hard Drive partitions

Use cfdisk or fdisk to create a similar geometry:

Device        Start       End   Sectors   Size Type
/dev/sda1      2048   8390655   8388608     4G Linux swap         ---> swap
/dev/sda2   8390656  71305215  62914560    30G Linux filesystem   ---> /
/dev/sda3  71305216 468862090 397556875 189.6G Linux filesystem   ---> /var

*Set the var partition to fit the size of the drive.*

#### Format the partitions

```
# mkswap /dev/sda1
# mkfs.xfs /dev/sda2
# mkfs.xfs /dev/sda3
```

#### Mount the partitions

```
# mount /dev/sda2 /mnt
# mkdir /mnt/var
# mount /dev/sda3 /mnt/var

```

### Unpack the stage4

Unpack the stage4 filesystem into the hard drive 

```
# cd /mnt
# tar -Jxf /sotolito/stage4/SotolitoOS-1.28-stage4-latest.tar.xz
# reboot

```

### Change the boot entry

Change the boot entry order

**Copy the /boot/extlinux/extlinux.conf.hd to /boot/extlinux/extlinux.conf**

```
cp /boot/extlinux/extlinux.conf.hd /boot/extlinux/extlinux.conf
```


*It should look like this*

label SotolitoOS-armv7hl-1.0 (vmlinuz-4.17.el7.centos.armv7hl)
        kernel /vmlinuz-4.17.el7.centos.armv7hl
        append ro root=/dev/sda2 rdloaddriver=sun4i-drm hdmi.audio=EDID:0 disp.screen0_output_mo
de=EDID:1280x720p60 quiet rhgb
        fdtdir /dtb-4.17.el7.centos.armv7hl/
        initrd /initramfs-4.17.0-rc1-sotolito+.img

label RESCUE-SotolitoOS-armv7hl-1.0 (vmlinuz-4.17.el7.centos.armv7hl)
        kernel /vmlinuz-4.17.el7.centos.armv7hl
        append ro root=UUID=7ea4a72f-1f7f-42c0-a0d6-f75138f2419b rdloaddriver=sun4i-drm hdmi.aud
io=EDID:0 disp.screen0_output_mode=EDID:1280x720p60 quiet rhgb
        fdtdir /dtb-4.17.el7.centos.armv7hl/
        initrd /initramfs-4.17.0-rc1-sotolito+.img

### Reboot

After the hard disk has been setup, the first boot might take a while since it will perform
SELinux autorelabel tasks.

### NOTES

- Remember to change the sotolito and root users password.
