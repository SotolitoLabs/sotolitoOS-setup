#!/bin/bash
clear
part=$(mount |grep '^/dev.* / ' |awk '{print $1}')
if [ -z "$part" ];then
    echo "Error detecting rootfs"
    exit -1
fi
dev=$(echo $part|sed 's/[0-9]*$//g')
devlen=${#dev}
num=${part:$devlen}
if [[ "$dev" =~ ^/dev/mmcblk[0-9]*p$ ]];then
    dev=${dev:0:-1}
fi
if [ ! -x /usr/bin/growpart ];then
    echo "Please install cloud-utils-growpart (sudo yum install cloud-utils-growpart)"
    exit -2
fi
if [ ! -x /usr/sbin/resize2fs ];then
    echo "Please install e2fsprogs (sudo yum install e2fsprogs)"
    exit -3
fi
echo $part $dev $num

echo "Extending partition $num to max size ...."
growpart $dev $num
echo "Resizing ext4 filesystem ..."
resize2fs $part
echo "Done."
df -h |grep $part

