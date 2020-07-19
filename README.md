# SotolitoOS
SotolitoOS is an CentOS spin that integrates extra configurations and packages for creating hybrid clouds and Sotolito Labs Appliances.

SotolitoOS is proudly maintained by the SotolitoLabs gang from Chihuahua. All the documentation and software around it is Open Source so feel free to use it enhance it and send us patches <3.

## SotolitoOS Distribution
There are three versions of SotolitoOS:

* **Basic**: Adds extra packages to the CentOS 8 stream installation
* **Master**: Installs a kubernetes master cluster and Ceph Configurations
* **Node**: Installs a kubernetes and Ceph node.

### Features

- Based on CentOS 8 Stream
- Preconfigure elrepo repository
- Pre-loaded Ansible Hardening playbooks with Security Technical Implementation Guide (STIG)
- Update to elrepo kernel-ml 5.6.2
- Cockpit web manager


## Download

### ISO: Download
The SotolitoOS x86_64 ISO can be downloaded from this location:

* https://sotolitolabs.com/dist/centos/8/x86_64/iso/SotolitoOS-Stream-x86_64-8.3-Stream-generic.iso

### RaspberryPi 3 and 4 image
* https://sotolitolabs.com/dist/centos/8/aarch64/Centos-8-aarch64-RaspberryPi.img.xz


### ISO: Creation
To create the SotolitoOS 8 stream ISO enter the `sotolitoOS-remix/scripts` directory and execute the `create-iso.sh` script.

```
scripts $ ./create-iso.sh generic 2>&1 | tee log-sotolito.log
```

After a succesful execution you shuld have the `SotolitoOS-Stream-x86_64-8-Stream-generic.iso` ISO in the `sotolito-iso` directory.





### RaspberryPi 3 and 4 Image creation
TODO
