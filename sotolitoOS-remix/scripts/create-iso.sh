#!/bin/bash

# Create the super duper SotolitoOS centos remix iso
# This scripts should be run from the scripts directory
# (c) SotolitoLabs
# Iván Chavero <ichavero@chavero.com.mx>
# This cute thing is licensed under the GPLv2 you know where to get it <3

# TODO make this a parameters
PREPARER="imcsk8"
BASE_IMAGE="CentOS-7-x86_64-Minimal-1810.iso"
KICKSTART_FILE="../ks/sotolitoOS.ks"
KERNEL_ML_PACKAGE="kernel-ml-5.2.9-1.el7.elrepo.x86_64.rpm"
KERNEL_ML_TOOLS_PACKAGE="kernel-ml-tools-5.2.9-1.el7.elrepo.x86_64.rpm"
KERNEL_MIRROR="http://repos.lax-noc.com/elrepo/archive/kernel/el7/x86_64/RPMS/"
ISO_NAME="SotolitoOS-7-x86_64-Minimal-1810.iso"

BASE_IMAGE_URL="http://mirrors.usc.edu/pub/linux/distributions/centos/7.6.1810/isos/x86_64/${BASE_IMAGE}"
KERNEL_ML_PACKAGE_URL="${KERNEL_MIRROR}/${KERNEL_ML_PACKAGE}"
KERNEL_ML_TOOLS_PACKAGE_URL="${KERNEL_MIRROR}/${KERNEL_ML_TOOLS_PACKAGE}"
# We use the same version as the centos base image
VERSION="7"

DATE=`date +%Y-%m-%d`
APPID="SotolitoLabs - ${DATE} - ${VERSION}"

echo "Installing required packages"
sudo dnf install -y createrepo genisoimage

echo "Creating the Enterprise SotolitoOS ISO instller"
mkdir -p sotolito-iso/isolinux/{images,ks,LiveOS,Packages,postinstall}
cd sotolito-iso
echo "Downloading base image"
wget -c $BASE_IMAGE_URL -O $BASE_IMAGE
mkdir iso
echo "Mouting base image"
sudo mount -o loop CentOS-7-x86_64-Minimal-1810.iso iso

echo "Preparing ISO environment"
cp iso/.discinfo isolinux/
cp iso/isolinux/* isolinux/
rsync -av iso/images/ isolinux/images/
cp iso/LiveOS/* isolinux/LiveOS/
#TODO automate the selection of this file
gunzip -c iso/repodata/d4de4d1e2d2597c177bb095da8f1ad794d69f76e8ac7ab1ba6340fdd0969e936-c7-minimal-x86_64-comps.xml.gz > comps.xml
rsync -av iso/Packages/ isolinux/Packages/
sudo umount iso

echo "Downloading extra packages"
cd isolinux/Packages
wget -c $KERNEL_ML_PACKAGE_URL
wget -c $KERNEL_ML_TOOLS_PACKAGE_URL

echo "Create image repo"
cd ..
createrepo -g ../comps.xml .

echo "Branding Image"
sed -i 's/CentOS/SotolitoOS/' isolinux.cfg
sed -i 's/nomodeset quiet/nomodeset quiet ks=cdrom:\/ks\/sotolitoOS.ks/' isolinux.cfg

echo "Adding Sotolito kickstar file to ISO"
cp ../ks/sotolitoOS.ks ks/

echo "Generate ISO image"
mkisofs -o "../${ISO_NAME}" \
    -p "${PREPARER}" \
    -A "${APPID}" \
    -b isolinux.bin \
    -c boot.cat \
    -no-emul-boot \
    -V 'SotolitoOS 7 x86_64' \
    -boot-load-size 4 \
    -boot-info-table \
    -R -J -v -T \
    .

