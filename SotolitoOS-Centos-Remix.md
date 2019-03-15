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

**Set green light on when the appliance is ready**


```
[Unit] 
Description=Sotolito OS ARM Control Ready Light (Green)
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/ligt_control.sh green on
RemainAfterExit=true
ExecStop=/usr/local/bin/ligt_control.sh green off
StandardOutput=journal

[Install]
WantedBy=multi-user.target
```


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
