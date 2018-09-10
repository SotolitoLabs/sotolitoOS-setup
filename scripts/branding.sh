#!/bin/bash

# Brand fedora upstream to SotolitoOS
# Iván Chavero <ichavero@chavero.com.mx>

DEFAULT_PASSWORD="sereke2018sotol(/"
DEFAULT_PATH="/run/media/${USERNAME}"

if [[ $1 == "" ]]; then
    MOUNT_PATH=$DEFAULT_PATH
else
    MOUNT_PATH=$1
fi

if [[ $2 == "" ]]; then
    PASSWORD=$DEFAULT_PASSWORD
else
    PASSWORD=$2
fi


ROOT="${MOUNT_PATH}/__"
BOOT="${MOUNT_PATH}/__boot"

echo "Branding system on ${MOUNT_PATH}"
echo "Creating user account"
echo "sotolito:x:1003:" >> ${ROOT}/etc/group
echo "sotolito:x:1002:1003:Sotolito OS Admin User:/home/sotolito:/bin/bash" >> ${ROOT}/etc/passwd
echo 'sotolito:$6$vtY7U03GVzGOkyvU$SwFIJc4nf7WLEVRSJV.DOhqBAO0dgUILZ/aONrnjph9x2WqJ7UBz0hpu8Xjr.vwPjuE9gQDin5rG2ST1axdtR/:17784:0:99999:7:::' >> ${ROOT}/etc/shadow
echo "Seting hostname and branding information"
echo "sotolito" > ${ROOT}/etc/hostname
cp ../etc/os-release ${ROOT}/etc/os-release
cp ../etc/system-release ${ROOT}/etc/system-release
mkdir ${ROOT}/etc/sotolito
cp -rp ../etc/sotolito ${ROOT}/etc/sotolito
cp -rp ../etc/profile.d etc/.
cp ../etc/modules-load.d/cubie.conf ${ROOT}/etc/modules-load.d/cubie.conf
rm ${ROOT}/etc/systemd/system/multi-user.target.wants/initial-setup.service
echo "Done!"

