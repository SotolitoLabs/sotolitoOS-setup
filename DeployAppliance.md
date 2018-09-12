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

### Change the boot entry

Change the boot entry order so it looks like this:

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

### NOTES

- Remember to change the sotito and root users password.
