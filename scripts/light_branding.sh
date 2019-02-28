#!/bin/bash

# Brand fedora upstream to SotolitoOS on a live system
# Iván Chavero <ichavero@chavero.com.mx>

echo "Seting hostname and branding information"
cp ../etc/os-release /etc/os-release
cp ../etc/system-release /etc/system-release
mkdir /etc/sotolito
cp -rp ../etc/sotolito /etc/sotolito
cp -rp ../etc/profile.d etc/.
echo "Done!"

