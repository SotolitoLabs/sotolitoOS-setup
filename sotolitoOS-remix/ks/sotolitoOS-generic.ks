#version=DEVEL
# System authorization information
auth --enableshadow --passalgo=sha512
# Use CDROM installation media
cdrom
# use graphical install
graphical
# Run the Setup Agent on first boot
firstboot --enable
# Keyboard layouts
#keyboard --vckeymap=us --xlayouts='us'
# System language
lang en_US.UTF-8

# Drive setup
#ignoredisk --only-use=vda
# System bootloader configuration
#bootloader --disabled
#autopart --type=plain --fstype=ext4 --nohome --noboot --noswap
# Clear the Master Boot Record
#zerombr
# Partition clearing information
#clearpart --all --initlabel

# Network information
# Main interface
network --bootproto=dhcp --ipv6=auto --activate --hostname=sotolito

# System services
services --disabled="chronyd"

%packages
#@^minimal
@core
elrepo-release
epel-release
kernel-ml
ansible
pcp
cockpit
cockpit-dashboard 
cockpit-podman
cockpit-pcp
#cockpit-selinux
cockpit-packagekit
cockpit-machines
#cockpit-networkmanager
podman
git
#ntp
dhcp-common
dhcp-client
sotolitoos-release
%end

services --enable=sshd,pmlogger,pmcd,cockpit.socket,cockpit.service
#firewall --enabled --service=dhcp --service=cockpit --service=ceph --service=ceph-mon --service=http --service=https
firewall --enabled --service=dhcp --service=cockpit --service=http --service=https

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
cp -rp /run/install/repo/postinstall/ansible /mnt/sysimage/etc/ansible
cp -rp /run/install/repo/postinstall/selinux /mnt/sysimage/home/sotolito/
%end


# enable elrepo for kernel updates
%post
sed -i 's/Cent/Sotolito/' /boot/grub2/grub.cfg
#Changed the name in honor of Octavio Mendez (octagesimal) sed -i 's/Core/Horilka/' /boot/grub2/grub.cfg
sed -i 's/Core/Octagesimal/' /boot/grub2/grub.cfg
# Fix DHCPD problem
ln -s /etc/centos-release /etc/sotolitoos-release
#rpm --import /root/RPM-GPG-KEY-elrepo.org
#rpm -Uvh /root/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
dnf --enablerepo=elrepo-kernel
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
restorecon -R -v /etc
#yum install -y yum-plugin-tmprepo
#yum install -y spacewalk-repo --tmprepo=https://copr-be.cloud.fedoraproject.org/results/%40spacewalkproject/spacewalk-2.9/epel-7-x86_64/repodata/repomd.xml --nogpg
%end



%anaconda
pwpolicy root --minlen=6 --minquality=1 --notstrict --nochanges --notempty
pwpolicy user --minlen=6 --minquality=1 --notstrict --nochanges --emptyok
pwpolicy luks --minlen=6 --minquality=1 --notstrict --nochanges --notempty
%end

reboot
