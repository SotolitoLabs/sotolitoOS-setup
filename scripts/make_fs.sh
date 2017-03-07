#!/bin/bash

echo "Creating filesystems"

echo "Creating swap..."
mkswap /dev/sda1
echo "Creating / filesystem"
mkfs.ext4 /dev/sda2
echo "Creating /var filesystem"
mkfs.xfs /dev/sda3
