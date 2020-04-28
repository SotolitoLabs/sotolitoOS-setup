#!/bin/bash

VIRT_IMAGES_PATH="/var/lib/libvirt/images"

rm SotolitoOS-Stream-x86_64-8.3-Stream-generic.iso
./create-iso.sh generic 2>&1 | tee log-sotolito.log
echo "Copying ISO to $VIRT_IMAGES_PATH"
sudo cp sotolito-iso/SotolitoOS-Stream-x86_64-8.3-Stream-generic.iso "${VIRT_IMAGES_PATH}/SotolitoOS-Stream-x86_64-8.3-Stream-generic.iso"

