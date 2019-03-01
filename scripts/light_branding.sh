#!/bin/bash

# Brand fedora upstream to SotolitoOS on a live system
# Iván Chavero <ichavero@chavero.com.mx>

ROOTDIR="~/moximo-setup"


echo "Branding hic hic!!"
cp ${ROOTDIR}/etc/sotolito-release /etc/.
ln -sf /etc/sotolito-release /etc/system-release
mkdir /etc/sotolito
cp -rp ${ROOTDIR}/etc/sotolito /etc/sotolito
cp -rp ${ROOTDIR}/etc/profile.d etc/.
echo "Done!"

