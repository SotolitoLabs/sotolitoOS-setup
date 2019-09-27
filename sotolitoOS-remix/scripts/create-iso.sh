#!/bin/bash

# Create the super duper SotolitoOS centos remix iso
# This scripts should be run from the scripts directory
# (c) SotolitoLabs
# Iván Chavero <ichavero@chavero.com.mx>
# This cute thing is licensed under the GPLv2 you know where to get it <3

# TODO make this a parameters
PREPARER="imcsk8"
BASE_IMAGE="CentOS-7-x86_64-Minimal-1810.iso"
KICKSTART_FILE="sotolitoOS-master.ks"
KERNEL_ML_PACKAGE="kernel-ml-5.2.9-1.el7.elrepo.x86_64.rpm"
KERNEL_ML_TOOLS_PACKAGE="kernel-ml-tools-5.2.9-1.el7.elrepo.x86_64.rpm"
KERNEL_MIRROR="http://repos.lax-noc.com/elrepo/archive/kernel/el7/x86_64/RPMS/"
ISO_NAME="SotolitoOS-7-x86_64-Minimal-1810-master.iso"
EL_REPO="https://www.elrepo.org"
EL_REPO_RPM="elrepo-release-7.0-4.el7.elrepo.noarch.rpm"
EL_REPO_RPM_GPG="RPM-GPG-KEY-elrepo.org"
FULL_PATH=$(realpath .)
PACKAGES_PATH="${FULL_PATH}/sotolito-iso/isolinux/Packages/"

BASE_IMAGE_URL="http://mirrors.usc.edu/pub/linux/distributions/centos/7.6.1810/isos/x86_64/${BASE_IMAGE}"
KERNEL_ML_PACKAGE_URL="${KERNEL_MIRROR}/${KERNEL_ML_PACKAGE}"
KERNEL_ML_TOOLS_PACKAGE_URL="${KERNEL_MIRROR}/${KERNEL_ML_TOOLS_PACKAGE}"
# We use the same version as the centos base image
VERSION="7"

DATE=`date +%Y-%m-%d`
APPID="SotolitoLabs - ${DATE} - ${VERSION}"

DEFAULT_SSH_KEYS_PATH="~/space/sotolitoLabs/security/ssh/"

if [[ "$1" == "node" ]]; then
	KICKSTART_FILE="sotolitoOS-node.ks"
	ISO_NAME="SotolitoOS-7-x86_64-Minimal-1810-node.iso"
fi

echo "Installing required packages"
sudo dnf install -y createrepo genisoimage podman

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
gunzip -c iso/repodata/*-comps.xml.gz > comps.xml
rsync -av iso/Packages/ isolinux/Packages/
sudo umount iso

echo "Downloading extra packages"
cd isolinux/Packages
cp ../../../files/RPMPS/sotolitoos-release* .
wget -c "${EL_REPO}/${EL_REPO_RPM}"
wget -c "${EL_REPO}/${EL_REPO_RPM_GPG}"
wget -c $KERNEL_ML_PACKAGE_URL
wget -c $KERNEL_ML_TOOLS_PACKAGE_URL

#cp "${FULL_PATH}/download_iso_packages.sh" $PACKAGES_PATH
#podman run --rm -ti --name=tmp-centos-pkgs -v $PACKAGES_PATH:/var/preserve registry.centos.org/centos/centos /var/preserve/download_iso_packages.sh

echo "Create image repo"
cd ..
createrepo -g ../comps.xml .

echo "Adding Sotolito kickstart file to ISO"
cp ../../ks/$KICKSTART_FILE ks/sotolitoOS.ks

echo "Copy branding for cockpit"
mkdir postinstall/branding
#TODO Fix this directory nightmare
cp -rp ../../../../usr/share/cockpit/branding/sotolito postinstall/branding/
cp ../../files/dhcpd.conf postinstall/
cp ../../../../etc/profile.d/sotolito_env.sh postinstall/
# We need our playbooks
cp -rp ../../../../ansible postinstall/
# SELinux shit
cp -rp ../../../../selinux postinstall/
cp ../../../../../security/ssh/* postinstall/

echo "Branding Image"
echo "Branding Boot menu"
sed -i 's/CentOS/SotolitoOS/' isolinux.cfg
sed -i 's/CentOS/SotolitoOS/' grub.cfg
sed -i 's/x86_64 quiet/x86_64 quiet ks=cdrom:\/ks\/sotolitoOS.ks/' isolinux.cfg
sed -i '/menu default/d' isolinux.cfg
sed -i 's/sotolitoOS.ks/sotolitoOS.ks\n  menu default/' isolinux.cfg

echo "Branding Initrd"
cd ..
mkdir tmp_initrd
cd tmp_initrd
xz -dc ../isolinux/initrd.img | sudo cpio -id
sudo cp ../../files/images/branding/sotolitoLabs_original_white_distro.png usr/share/pixmaps/system-logo-white.png
sudo sed -i 's/CentOS/SotolitoOS/' .buildstamp
sudo sed -i 's/CentOS/SotolitoOS/' etc/initrd-release
sudo sed -i 's/dracut/SotolitoOS/' etc/initrd-release
sudo sed -i 's/Core/Gin/' etc/initrd-release
sudo find . | cpio --create --format='newc' > ../isolinux/initrd.img
cd ../isolinux
sudo xz --format=lzma initrd.img
sudo mv initrd.img.lzma initrd.img

echo "Adding sotolito squashfs"
cp ../../files/squashfs-sotolito.img LiveOS/squashfs.img
echo "Add product.img for branding the installer"
cp ../../../anaconda/branding/product.img images/

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
    -l -r -R -v -T \
    .

isohybrid "../${ISO_NAME}"

echo "Be happy, drink a beer and a shot of sotol"
