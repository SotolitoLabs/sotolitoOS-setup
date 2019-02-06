## Cubietruck Plus notes

### WIFI

The wifi driver need additional firmware setup

**Get the firmware files**
```
curl https://raw.githubusercontent.com/OpenELEC/wlan-firmware/master/firmware/brcm/brcmfmac4330-sdio.txt > /lib/firmware/brcm/brcmfmac4330-sdio.txt
curl https://raw.githubusercontent.com/OpenELEC/wlan-firmware/master/firmware/brcm/brcmfmac43340-sdio.bin > /lib/firmware/brcm/brcmfmac43340-sdio.bin
```

**Configure load on boot**
```
echo ac100  > /etc/modules-load.dac100.conf
echo rtc-ac100 > /etc/modules-load.d/rtc-ac100.conf
echo brcmfmac > /etc/modules-load.d/brcmfmac.conf
echo sun4i-drm-hdmi > /etc/modules-load.d/sun4i-drm-hdmi.conf
```


### References
- http://linuxwireless.sipsolutions.net/en/users/Drivers/brcm80211/__v59.html#Firmware_installation-1
