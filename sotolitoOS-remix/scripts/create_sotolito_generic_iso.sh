#!/bin/bash

rm sotolito-iso/SotolitoOS-Stream-x86_64-8-Stream-generic.iso
rm log-sotolito.log
./create-iso.sh generic 2>&1 | tee log-sotolito.log
cp sotolito-iso/SotolitoOS-Stream-x86_64-8-Stream-generic.iso ~/space/virt-images/

