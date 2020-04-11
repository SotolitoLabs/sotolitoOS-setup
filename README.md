# SotolitoOS Images
SotolitoOS is an CentOS spin that integrates extra configurations and packages for create kubernetes clusters and Sotolito Appliances.

## SotolitoO Distribution
There are three versions of SotolitoOS:

* **Basic**: Adds extra packages to the CentOS 8 stream installation
* **Master**: Installs a kubernetes master cluster and Ceph Configurations
* **Node**: Installs a kubernetes and Ceph node.

### ISO: Download
The SotolitoOS x86_64 ISO can be downloaded from this location:

* https://sotolitolabs.com/dist/centos/8/x86_64/iso/SotolitoOS-Stream-x86_64-8-Stream-generic.iso


### ISO: Creation
To create the SotolitoOS 8 stream ISO enter the `sotolitoOS-remix/scripts` directory and execute the `create-iso.sh` script.

```
scripts $ ./create-iso.sh generic 2>&1 | tee log-sotolito.log
```

After a succesful execution you shuld have the `SotolitoOS-Stream-x86_64-8-Stream-generic.iso` ISO in the `sotolito-iso` directory.





### RaspberryPi 3 and 4 Image creation
TODO
