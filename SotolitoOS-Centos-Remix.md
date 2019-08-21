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

**Or download the current SotolitoOS-Centos Cubietruck Plus Remix and write it to the sdcard**

```
$ wget http://sotolitolabs.com/dist/1.7/centos/images/SotolitoOS-Cubietruck_Plus-CentOS-Userland-7-armv7hl-generic-Minimal-419-v26-1810-sda.raw.xz
$ xz -d SotolitoOS-Cubietruck_Plus-CentOS-Userland-7-armv7hl-generic-Minimal-419-v26-1810-sda.raw.xz
$ sudo dd if=SotolitoOS-Cubietruck_Plus-CentOS-Userland-7-armv7hl-generic-Minimal-419-v26-1810-sda.raw of=/dev/sdc status=progress bs=16M

```

# Ansible Deployment

### Install git and ansible

```
~# yum install -y git ansible
```

### Clone the github repo

```
~# cd /home/sotolito/
sotolito # git clone https://github.com/SotolitoLabs/moximo-setup.git
```

### Low level deployment

**TODO** Extend to perform this on múltiple nodes

**Don't check host key**
```
sotolito # sed -i s/#host_key_checking/host_key_checking/ /etc/ansible/ansible.cfg
```

**Run The playbook**
```
sotolito # cd moximo-setup/ansible/
ansible # ansible-playbook --ask-pass -i 127.0.0.1, ansible/playbooks/low-level-setup/bootstrap.yaml
```

### Cluster Setup

**Run the playbook**
```
sotolito # ansible-playbook --ask-pass -i 127.0.0.1, ansible/playbooks/cluster-setup.yaml
```


# Manual Deployment

## Configure SSD partitions

### Create local user sotolito

`~# useradd -c "Moximo Cloud Appliance Admin User" sotolito`

### Clone code repo

This has to be performed as user sotolito, so change user before cloning

```
su - sotolito
git clone https://github.com/SotolitoLabs/moximo-setup.git  
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

If you're using SELinux you have to relabel the filesystem

```
# touch /mnt/.autorelabel
```

Finally, unmount mounting points and delete directories in /mnt/

```
cd ~
umount /mnt/sotolito/var
umount /mnt/sotolito
rm -rf /mnt/*
```

### Create initramfs
There are some modules that are needed for booting using /dev/sda2 as root filesystem:

#### dracut

Add this to */etc/dracut.conf.d/99-extradrivers.conf*
```
force_drivers+=" phy-sun4i-usb ac100 sunxi-rsb axp20x-rsb axp20x-regulator axp20
x-pek axp20x_ac_power axp20x_battery axp20x_usb_power axp288_fuel_gauge rtc-ac10
0 usb-storage uas ehci-platform xfs usb3503 ehci-platform
```

Create new initramfs

```
# dracut -v -M -f /boot/initramfs-4.19.7-300.el7.armv7hl-sotolito.img
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


**Optional: Monitoring service**
*This is used for development*

in /etc/systemd/system/sotolitoos-monitoring-discovery.service
```
[Unit] 
Description=Sotolito OS Monitoring Discovery
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/monitoring_discovery.sh start
RemainAfterExit=true
ExecStop=/usr/local/bin/monitoring_discovery.sh stop
StandardOutput=journal

[Install]
WantedBy=multi-user.target

```

in /usr/local/bin/monitoring_discovery.sh

```
#!/bin/bash

LOCAL_IP=$(ip addr show eth0 | grep -Po 'inet \K[\d.]+')
ACTION="Started"

if [[ $1 != "start" ]]; then
  ACTION="Stopped"
fi

res=$(curl -XGET "http://sotolitolabs.com/monitoring/control.php?local_ip=${LOCAL_IP}&action=${A
CTION}")

echo "RES: ${res}"
```

```
# systemctl daemon-reload
# systemctl enable sotolitoos-monitoring-discovery
```



# References

* http://linux-sunxi.org/Cubieboard/Programming/StatusLEDs
