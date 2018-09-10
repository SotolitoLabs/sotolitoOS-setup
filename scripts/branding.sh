#!/bin/bash

# Brand fedora upstream to SotolitoOS
# Iván Chavero <ichavero@chavero.com.mx>

DEFAULT_PASSWORD="sereke2018sotol(/"
DEFAULT_PATH="/run/media/${USERNAME}"

if [[ $1 == "" ]]; then
    PASSWORD=$DEFAULT_PASSWORD
fi

if [[ $2 == "" ]]; then
    MOUNT_PATH=$DEFAULT_PATH
fi


ROOT="${MOUNT_PATH}/__"
BOOT="${MOUNT_PATH}/__"

echo "Branding Live system"
useradd -R ${ROOT} -m -c "Sotolito OS Admin User" -s /bin/bash -d /home/sotolito sotolito
echo -e "${PASSWORD}\n${PASSWORD}" | passwd sotolito
echo "sotolito" > ${ROOT}/etc/hostname
cp ../etc/os-release ${ROOT}/etc/os-release
cp ../etc/system-release ${ROOT}/etc/system-release
mkdir ${ROOT}/etc/sotolito
cp -rp ../etc/images ${ROOT}/etc/sotolito/.



