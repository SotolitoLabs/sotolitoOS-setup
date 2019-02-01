##  Sotolito OS Image management

We currently pack the base system in a image for Cubietruck Plus but can be
adapted for any board just by adding the proper uboot data.

### Modify image 

We make the image partitions available using losetup

```
# losetup -P /dev/loop0 SotolitoOS-1.28-SD.img 
```

**NOTE** 
The -P switch makes the partitions inside the image avaiable to the system.

Verify that we have the paritions

```
# fdisk -l /dev/loop0
Disk /dev/loop0: 3.4 GiB, 3674210304 bytes, 7176192 sectors
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0xbfd609ad

Device       Boot   Start     End Sectors  Size Id Type
/dev/loop0p1         2048   61439   59392   29M  c W95 FAT32 (LBA)
/dev/loop0p2 *      61440 1060863  999424  488M 83 Linux
/dev/loop0p3      1060864 2060287  999424  488M 82 Linux swap / Solaris
/dev/loop0p4      2060288 6942719 4882432  2.3G 82 Linux filesystem
```

Mount a partition (eg. boot)

```
# mount /dev/loop0p2 /mnt
```

After making modifications remove the loop device.

```
#
```

Be happy :D
