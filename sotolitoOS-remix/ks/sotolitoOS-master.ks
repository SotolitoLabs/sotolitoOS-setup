#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
# use text install
text
# Run the Setup Agent on first boot
firstboot --enable
# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Check for the first fixed hard disk

# include the partitioning logic from the pre section.
%include /tmp/part-include

# From: https://www.redhat.com/archives/kickstart-list/2012-October/msg00014.html
%pre --log=/tmp/sotolito-pre.log
echo "Setting up as MASTER"
# pre section
#----- partitioning logic below--------------
# pick the first drive that is not removable and is over MINSIZE
DIR="/sys/block"
ROOTDRIVE="sdb"

# minimum size of hard drive needed specified in GIGABYTES
MINSIZE=10

for DEV in sda sdb sdc sdd hda hdb; do
  if [ -d $DIR/$DEV ]; then
    REMOVABLE=`cat $DIR/$DEV/removable`
    if (( $REMOVABLE == 0 )); then
      echo $DEV
      SIZE=`cat $DIR/$DEV/size`
      GB=$(($SIZE/2**21))
      if [ $GB -gt $MINSIZE ]; then
        echo "$(($SIZE/2**21))"
		ROOTDRIVE=$DEV
      fi
    fi
  fi
done

ROOT_PART_SIZE=$(($MINSIZE*1024))
echo "Installing on ${ROOTDRIVE}"
cat << EOF > /tmp/part-include
# Drive setup
ignoredisk --only-use=$ROOTDRIVE
zerombr
clearpart --all --initlabel --drives=$ROOTDRIVE
# System bootloader configuration
bootloader --location=mbr --boot-drive=$ROOTDRIVE
# Partition clearing information
part biosboot --fstype=biosboot --size=1
part /boot    --fstype="xfs" --size=1024
part pv.sotolito --fstype="lvm" --size=1 --grow
volgroup sotolito pv.sotolito
logvol /    --fstype="xfs"  --size=$ROOT_PART_SIZE --label="sotolito-root" --name=sotolito-root --vgname=sotolito
logvol swap --fstype="swap" --size=2048  --label="sotolito-swap" --name=sotolito-swap --vgname=sotolito
logvol /var --fstype="xfs"  --size=1     --label="sotolito-var"  --name=sotolito-var  --vgname=sotolito --grow
EOF

%end

# Network information
# Main interface
network --bootproto=dhcp --ipv6=auto --activate
# TODO: Virtual interfaces for management
network --bootproto=static --vlanid=1 --ip=10.253.0.1 --netmask=255.255.255.0 --activate --onboot=on
network --bootproto=static --vlanid=2 --ip=192.168.1.253 --netmask=255.255.255.0 --activate --onboot=on
network --hostname=sotolito-master

# Root password
rootpw --iscrypted $6$UP1RIgyqnitFKfQM$UtyjaK8sVCDyGYFTHL4tTe9b69M.MPloYPpSuhX2JHyMkOG8eXajQBSAukPP1Z//S08WDzBKv8Jhmjq7Bhe1D.
# System services
services --disabled="chronyd"
# System timezone
timezone America/Mexico_City --isUtc --nontp
user --groups=wheel --name=sotolito --password=$6$Cw/RUY/qBrrhnmh7$yQtPlZi4md8joMVRYNUaCaxHZeVFfRrWk2mJvzO9xwfYdwQx5XHSDdWmPPyyrPI6MgMq5p6IO8OepOKJJ0QBR0 --iscrypted --gecos="Sotolito Labs "

%packages
@^minimal
@core
kernel-ml
ansible
pcp
cockpit
cockpit-dashboard 
cockpit-docker
cockpit-pcp
docker
sotolitoos-release
#podman stick with docker for this one :'(
git
dhcp-common
dhcp

%end

services --enable=sshd,dhcpd,pmlogger,pmcd,cockpit.socket,cockpit.service
firewall --enabled --service=dhcp --service=cockpit --service=ceph --service=ceph-mon --service=http --service=https

%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

# Poor man's Branding

# Copy files to installed system
# Check how to avoid the version package for elrepo
%post --nochroot
cp -rp /run/install/repo/postinstall/branding/sotolito /mnt/sysimage/usr/share/cockpit/branding/
cp /run/install/repo/postinstall/dhcpd.conf /mnt/sysimage/etc/dhcp/
cp /run/install/repo/postinstall/sotolito_env.sh /mnt/sysimage/etc/profile.d/sotolito_env.sh
mkdir /mnt/sysimage/root/.ssh
chmod 0700 /mnt/sysimage/root/.ssh
cp /run/install/repo/postinstall/sotolito_id_rsa* /mnt/sysimage/root/.ssh/
cp -rp /run/install/repo/postinstall/ansible /mnt/sysimage/etc/ansible/sotolito
cp -rp /run/install/repo/postinstall/selinux /mnt/sysimage/home/sotolito/
%end


# enable elrepo for kernel updates
%post
sed -i 's/Cent/Sotolito/' /boot/grub2/grub.cfg
sed -i 's/Core/Gin/' /boot/grub2/grub.cfg
# Fix DHCPD problem
sed  -i '/^VLAN_FLAGS="NO_REORDER_HDR"$/d' /etc/sysconfig/network-scripts/ifcfg-eth0.1
ln -s /etc/centos-release /etc/sotolitoos-release
#rpm --import /root/RPM-GPG-KEY-elrepo.org
#rpm -Uvh /root/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
yum --enablerepo=elrepo-kernel
# the service directiva can't enable cockpit.socket so we have to do it manually
systemctl enable cockpit.socket
systemctl enable cockpit.service
#Generate ssh keypair
ssh-keygen -f /root/.ssh/id_rsa -q -N ""
cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
cat /root/.ssh/sotolito_id_rsa.pub >> /root/.ssh/authorized_keys
# Configure ansible
echo "host_key_checking = False" >> /etc/ansible/ansible.cfg
echo "retry_files_enabled = False" >> /etc/ansible/ansible.cfg
# Prepare our dhcp bootstrap
usermod -d /etc/dhcp/scripts dhcpd
mkdir /etc/dhcp/scripts/.ssh
cp /root/.ssh/sotolito_id_rsa* /etc/dhcp/scripts/.ssh/
cp /etc/ansible/sotolito/setup_sotolito_node.sh /etc/dhcp/scripts/
cp /root/.ssh/id_rsa.pub /etc/ansible/sotolito/playbooks/master_id_rsa.pub
chgrp  dhcpd /etc/dhcp/
chown -R dhcpd:dhcpd /etc/dhcp/scripts/
chmod 0755 /etc/dhcp/scripts/setup_sotolito_node.sh
chown -R dhcpd:dhcpd /etc/dhcp/scripts/.ssh
chmod 0600 /etc/dhcp/scripts/.ssh/sotolito_id_rsa
restorecon -R -v /etc
semodule -i /home/sotolito/selinux/dhcp_sotolito_node_bootstrap.pp
#yum install -y yum-plugin-tmprepo
#yum install -y spacewalk-repo --tmprepo=https://copr-be.cloud.fedoraproject.org/results/%40spacewalkproject/spacewalk-2.9/epel-7-x86_64/repodata/repomd.xml --nogpg
%end



%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

reboot
