#!/bin/bash

# Create the super duper SotolitoOS centos remix iso
# This scripts should be run from the scripts directory
# (c) SotolitoLabs
# Iván Chavero <ichavero@chavero.com.mx>
# This cute thing is licensed under the GPLv2 you know where to get it <3

# TODO make this a parameters
PREPARER="imcsk8"
BASE_IMAGE="CentOS-Stream-x86_64-boot.iso"
KICKSTART_FILE="sotolitoOS-generic.ks"
KERNEL_ML_PACKAGE="kernel-ml-5.6.2-1.el8.elrepo.x86_64.rpm"
KERNEL_ML_TOOLS_PACKAGE="kernel-ml-tools-5.6.2-1.el8.elrepo.x86_64.rpm"
KERNEL_MIRROR="http://repos.lax-noc.com/elrepo/archive/kernel/el8/x86_64/RPMS/"
#ISO_NAME="SotolitoOS-Stream-x86_64-master.iso"
ISO_NAME="SotolitoOS-Stream-x86_64-generic.iso"
EL_REPO="https://www.elrepo.org"
EL_REPO_RPM="elrepo-release-8.el8.elrepo.noarch.rpm"
EL_REPO_RPM_GPG="RPM-GPG-KEY-elrepo.org"
EPEL_REPO="https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm"
FULL_PATH=$(realpath .)
#PACKAGES_PATH="${FULL_PATH}/sotolito-iso/iso-dev/isolinux/Packages/"
PACKAGES_PATH="${FULL_PATH}/sotolito-iso/iso-dev/Packages/"

echo "DEBUG: PACKAGES PATH: ${PACKAGES_PATH}"

#BASE_IMAGE_URL="http://mirrors.usc.edu/pub/linux/distributions/centos/7.6.1810/isos/x86_64/${BASE_IMAGE}"
BASE_IMAGE_URL="http://mirror.keystealth.org/centos/8-stream/isos/x86_64/CentOS-Stream-8-x86_64-20210421-boot.iso"
KERNEL_ML_PACKAGE_URL="${KERNEL_MIRROR}/${KERNEL_ML_PACKAGE}"
KERNEL_ML_TOOLS_PACKAGE_URL="${KERNEL_MIRROR}/${KERNEL_ML_TOOLS_PACKAGE}"
# We use the same version as the centos base image
VERSION="8.3-Stream"

DATE=`date +%Y-%m-%d`
APPID="SotolitoLabs - ${DATE} - ${VERSION}"

DEFAULT_SSH_KEYS_PATH="~/space/sotolitoLabs/security/ssh/"

#SQUASHFS_FILE="squashfs-sotolito.img"
SQUASHFS_FILE="squashfs-sotolito-stream.img"
SQUASHFS_URL="https://sotolitolabs.com/dist/centos/8/x86_64/branding/img/${SQUASHFS_FILE}"

if [[ "${1}" != "" ]]; then
    KICKSTART_FILE="sotolitoOS-${1}.ks"
    ISO_NAME="SotolitoOS-Stream-x86_64-${VERSION}-${1}.iso"
fi

echo "Installing required packages"
sudo dnf install -y createrepo_c createrepo genisoimage podman git

echo "Checkig for repo2module"
if [[ "$(command -v repo2moduleee)" != "" ]]; then
    echo "repo2module detected, continuing"
else
    echo "missing repo2module, installing..."
    git clone https://github.com/sgallagher/repo2module.git
    cd repo2module
    python3 setup.py install --user
    cd ..
fi

echo "Creating the Enterprise SotolitoOS ISO instller"
mkdir -p sotolito-iso/iso-dev/{isolinux,images,ks,EFI,postinstall}
#mkdir -p sotolito-iso/iso-dev/isolinux/Packages
mkdir -p sotolito-iso/iso-dev/Packages
cd sotolito-iso
echo "Downloading base image"
wget -c $BASE_IMAGE_URL -O $BASE_IMAGE
mkdir iso
echo "Mouting base image"
sudo mount -o loop $BASE_IMAGE iso

echo "Preparing ISO environment"
rsync -av iso/isolinux/ iso-dev/isolinux/
rsync -av iso/images/ iso-dev/images/
sudo rsync -av iso/EFI/ iso-dev/EFI/

echo "Downloading extra packages"
#cd iso-dev/isolinux/Packages
cd iso-dev/Packages
cp ../../../../files/RPMS/sotolitoos-release* .
wget -c "${EL_REPO}/${EL_REPO_RPM}"
wget -c "${EL_REPO}/${EL_REPO_RPM_GPG}"
#wget -c $KERNEL_ML_PACKAGE_URL
#wget -c $KERNEL_ML_TOOLS_PACKAGE_URL
wget -c $EPEL_REPO

cp "${FULL_PATH}/download_iso_packages.sh" $PACKAGES_PATH
/usr/bin/podman run --rm -ti --name=tmp-centos-pkgs -v $PACKAGES_PATH:/var/preserve registry.centos.org/centos/centos:8 /var/preserve/download_iso_packages.sh

echo "Create image repo"
cd ..
rm -rf repodata
createrepo_c -g ../../files/sotolito-comps-BaseOS.x86_64.xml  .
repo2module --module-name=sotolito-core --module-context sotolito1 . modules.yaml
modifyrepo_c --mdtype=modules modules.yaml repodata
rm modules.yaml

echo "Adding Sotolito kickstart file to ISO"
cp ../../../ks/$KICKSTART_FILE ks/sotolitoOS.ks

echo "Copy branding for cockpit"
mkdir postinstall/branding
#TODO Fix this directory nightmare
cp -rp ../../../../usr/share/cockpit/branding/sotolito postinstall/branding/
cp ../../files/dhcpd.conf postinstall/
cp ../../../../etc/profile.d/sotolito_env.sh postinstall/
# We like ansible
mkdir postinstall/ansible
# We need our playbooks
cp -rp ../../../../ansible postinstall/ansible/sotolito
# Install ansible-hardening role for STIG compliance
if [[ ! -d postinstall/ansible/roles/ansible-hardening ]]; then
    echo "Downloading ansible-hardening role"
    mkdir -p postinstall/ansible/roles
    git clone https://github.com/openstack/ansible-hardening postinstall/ansible/roles/ansible-hardening
fi

# SELinux shit
cp -rp ../../../../selinux postinstall/
cp ../../../../../security/ssh/* postinstall/

cd isolinux
echo "Branding Image"
echo "Branding Boot menu"
sed -i 's/CentOS/SotolitoOS/' isolinux.cfg
#sed -i 's/CentOS/SotolitoOS/' grub.cfg
sed -i 's/CentOS/SotolitoOS/' grub.conf
#sed -i 's/-x86_64-dvd/ rd.retry=10 rd.timeout=15 \n menu default/' isolinux.cfg
sed -i 's/menu default//' isolinux.cfg
if [[ "${1}" == "generic" ]]; then
    sed -i 's/-x86_64-dvd quiet/ quiet rd.retry=10 rd.timeout=15\n  menu default/' isolinux.cfg
else
    sed -i 's/-x86_64-dvd quiet/ quiet rd.retry=10 rd.timeout=15  ks=cdrom:\/ks\/sotolitoOS.ks\n  menu default/' isolinux.cfg
fi

# poor man's branding
echo "Branding Initrd"
cd ..
mkdir tmp_initrd
cd tmp_initrd
xz -dc ../isolinux/initrd.img | sudo cpio -id
sudo cp ../../../files/images/branding/sotolitoLabs_original_white_distro.png usr/share/pixmaps/system-logo-white.png
sudo sed -i 's/CentOS/SotolitoOS/' .buildstamp
sudo sed -i 's/CentOS/SotolitoOS/' etc/initrd-release
sudo sed -i 's/dracut/SotolitoOS/' etc/initrd-release
#Changed the name in honor of Octavio Mendez (octagesimal) sudo sed -i 's/Core/Horilka/' etc/initrd-release
sudo sed -i 's/Core/Octagesimal/' etc/initrd-release
sudo sed -i 's/rmdir/rm -rf/' usr/sbin/fetch-kickstart-disk
sudo find . | sudo cpio --create --format='newc' > ../isolinux/initrd.img
cd ../isolinux
sudo xz --format=lzma initrd.img
sudo mv initrd.img.lzma initrd.img
sudo rm -rf ../tmp_initrd

cd ..
chmod +w images
echo "Adding sotolito squashfs"
wget -c ${SQUASHFS_URL} -O images/install.img
echo "Add product.img for branding the installer"
cp ../../../anaconda/branding/product.img images/


echo "Generate ISO image"
sudo mkisofs -o "../${ISO_NAME}" \
    -p "${PREPARER}" \
    -A "${APPID}" \
    -b isolinux/isolinux.bin \
    -c isolinux/boot.cat \
    -no-emul-boot \
    -V 'SotolitoOS-Stream-8' \
    -boot-load-size 4 \
    -boot-info-table \
    -l -r -R -v -T \
    .


sudo isohybrid "../${ISO_NAME}"
sudo chown $USER "../${ISO_NAME}"
cd ..
echo "Your iso is ready at: ${PWD}/${ISO_NAME} sir"
echo "share it with your friends and be happy, drink a beer and a shot of sotol"
