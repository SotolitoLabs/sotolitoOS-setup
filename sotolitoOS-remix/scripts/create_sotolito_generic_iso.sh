#!/bin/bash

VIRT_IMAGES_PATH="~/space/virt-images"

rm sotolito-iso/SotolitoOS-Stream-x86_64-8-Stream-generic.iso
rm log-sotolito.log
./create-iso.sh generic 2>&1 | tee log-sotolito.log
sudo cp sotolito-iso/SotolitoOS-Stream-x86_64-8-Stream-generic.iso ${VIRT_IMAGES_PATH}/.

