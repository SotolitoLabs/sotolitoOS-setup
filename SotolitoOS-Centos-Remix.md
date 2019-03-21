# CentOS SotolitoOS Remix

**Save the CentOS image to sdcard**

```
# dd if=CentOS-Userland-7-armv7hl-generic-Minimal-419-v26-1810-sda.raw of=/dev/sdc status=progress bs=16M
```

**Save U-Boot to the SD Card**
```
# dd if=u-boot-sunxi-with-spl.bin of=${card} bs=1024 seek=8
```

**Save Image with the proper U-Boot**

```
# dd if=/dev/sdc of=SotolitoOS-Cubietruck_Plus-CentOS-Userland-7-armv7hl-generic-Minimal-419-v26-1810-sda.raw bs=16M count=188
```

## Configure SSD partitions

### Create local user sotolito

`useradd -c "Moximo Cloud Appliance Admin User" sotolito`

### Clone code repo

This has to be performed as user sotolito, so change user before cloning

```
su - sotolito
git clone https://github.com/SotolitoLabs/sotolito-setup.git  
exit
```

### Copy filesystem structure from file to hard drive

`sfdisk /dev/sda < /home/sotolito/sotolito-setup/sys/hd/sdd.sfdisk`


### Extend hard drive's third partition (var) to maximum space available

For this task you may use parted or some other partition management tool.

If CLI is preferred, then issue the following command

`echo ", +" | sfdisk -N 3 /dev/sda`

### Copy root partition from SD Card to hard drive

In order to accomplish this, we need -first of all- format the hard drive's partitions as follows:

- /dev/sda1 as swap
- /dev/sda2 as xfs
- /dev/sda3 as xfs

```
mkswap /dev/sda1
mkfs.ext4 /dev/sda2
mkfs.xfs /dev/sda3
```

Then we create the directories for the mounting points:

```
mkdir -p /mnt/sotolito
mount /dev/sda2 /mnt/sotolito

mkdir /mnt/sotolito/var
mount /dev/sda3 /mnt/sotolito/var
```

Next we tar the root directory, excluding mnt

`tar --exclude=/mnt -c / > /mnt/sotolito/var/sotolito.tar`

And untar recently created file in /mnt/sda3

```
cd /mnt/sotolito/
tar -x ./var/sotolito.tar 
```
Modify /etc/fstab

```
/dev/sda1          swap swap      defaults,noatime 0 0
/dev/mmcblk1p2     /boot ext4     defaults,noatime 0 0
/dev/sda2          / xfs          defaults,noatime 0 0
/dev/sda3          /var xfs       defaults,noatime 0 0

```

Finally, unmount mounting points and delete directories in /mnt/

```
cd ~
umount /mnt/sotolito/var
umount /mnt/sotolito
rm -rf /mnt/*
```


### Change boot Configuration

This has to be done in order to command the system to use hard drive's newly copied root partition instead of the one in the SD Card

Edit /boot/extlinux/extlinux.conf and substitute root=UUID for root=/dev/sda2

Label may be customized as well.

Reboot system so next boot will run root on hard drive

`shutdown -r now`




## Miscelaneous configuration

**Set green light on when the appliance is ready**


*create the file /etc/systemd/system/sotolitoos-arm-control-ready-light.service*
```
[Unit] 
Description=Sotolito OS ARM Control Ready Light (Green)
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/light_control.sh green on
RemainAfterExit=true
ExecStop=/usr/local/bin/light_control.sh green off
StandardOutput=journal

[Install]
WantedBy=multi-user.target
```

```
# systemctl daemon-reload
```

*Turn on ready light (the green led)*
```
# systemctl start sotolitoos-arm-control-ready-light
```

*Turn off ready light*
```
# systemctl stop sotolitoos-arm-control-ready-light
```

*The ready light should be set on boot*

```
# systemctl enable sotolitoos-arm-control-ready-light
```

*The ready light should indicate that the system booted successfully*

## Misc.

**Control Lights**

```
#!/bin/bash

VALUE=0

if [[ $2 == "on" ]]; then
  VALUE=255
fi

if [[ $1 == "all" ]]; then
  for color in "blue" "orange" "green" "white"; do
    echo "Setting ${color} led to ${2}"
    echo $VALUE > /sys/class/leds/cubietruck-plus\:$color\:usr/brightness
  done
else
  echo $VALUE > /sys/class/leds/cubietruck-plus\:$1\:usr/brightness
fi

```






# References

* http://linux-sunxi.org/Cubieboard/Programming/StatusLEDs
