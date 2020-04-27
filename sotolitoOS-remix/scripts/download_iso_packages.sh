#!/bin/bash

echo "Installing EPEL"
dnf install -y /var/preserve/epel-release-latest-8.noarch.rpm

echo "Install ELREPO"
dnf install -y https://www.elrepo.org/elrepo-release-8.el8.elrepo.noarch.rpm

echo "Downloading packages"
dnf update -y --downloadonly --downloaddir=/var/preserve --releasever=8

mkdir /tmp-installroot
ln -s /etc /tmp-installroot/
echo "Downloading Group CentOS Stream Packages"
dnf groupinstall -y --downloadonly --downloaddir=/var/preserve --skip-broken --installroot=/tmp-installroot --releasever=8 \
  core base headless-management network-tools networkmanager-submodules performance

echo "Downloading Repo Packages"
echo "Downloading Stream Packages"
dnf install -y --downloadonly --downloaddir=/var/preserve --installroot=/tmp-installroot \
    --releasever=8 iproute iproute-tc grub2 systemd systemd-container libvirt-daemon-kvm
echo "Downloading SotolitoOS Packages"
dnf install -y --downloadonly --downloaddir=/var/preserve --installroot=/tmp-installroot \
    --releasever=8 cockpit git ansible skopeo podman \
    NetworkManager-tui NetworkManager-wifi device-mapper cockpit-podman cockpit-selinux cockpit-machines cockpit-networkmanager \
    device-mapper-event device-mapper-event-libs lvm2 cockpit-dashboard cockpit-pcp cockpit-storaged cockpit-packagekit pcp \
    cockpit-ws NetworkManager-config-server hostname filesystem dhcp-client procps-ng basesystem dhcp-common rootfiles coreutils \
    NetworkManager NetworkManager-team sssd-kcm sssd-common

echo "Downloading ELRepo Packages"
dnf install -y --downloadonly --downloaddir=/var/preserve --installroot=/tmp-installroot \
    --enablerepo=elrepo-kernel --releasever=8 kernel-ml
