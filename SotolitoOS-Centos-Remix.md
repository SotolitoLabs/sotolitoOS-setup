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
