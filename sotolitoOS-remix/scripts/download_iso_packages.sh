#!/bin/bash

echo "Downloading packages"
yum install -y --downloadonly --downloaddir=/var/preserve cockpit git ansible skopeo podman
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
#The container needs some packages in order to download the kernel
yum install -y --enablerepo="elrepo-kernel" kernel-ml
yum install -y --disablerepo="*" --enablerepo="elrepo-kernel" --downloadonly --downloaddir=/var/preserve kernel-ml
