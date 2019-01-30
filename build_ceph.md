# Build Ceph for SotolitoOs

Since the upstream ceph team does not build package 

## Install RPM build tools

```
# dnf install rpm-build rpmdevtools -y
# dnf install -y 
```

Install build dependencies

```
# dnf install -y CUnit-devel Cython3 boost-random cmake expat-devel fuse-devel gperf gperftools-devel java-devel jq junit keyutils-libs-devel leveldb-devel libaio-devel libbabeltrace-devel libblkid-devel libcurl-devel libibverbs-devel liboath-devel libudev-devel libuuid-devel libxml2-devel lttng-ust-devel lz4-devel nss-devel openldap-devel openssl-devel perl python3-Cython python3-devel python3-sphinx redhat-lsb-core selinux-policy-devel sharutils snappy-devel valgrind-devel xfsprogs-devel xmlstarlet yasm
```

**As a regular user**

*For this document we'll build mimic (13.2.4)*

```
$ rpmdev-setuptree
$ wget wget -O ~/rpmbuild/SOURCES/ceph-13.2.4.orig.tar.gz https://download.ceph.com/tarballs/ceph_13.2.4.orig.tar.gz https://download.ceph.com/tarballs/ceph_13.2.4.orig.tar.gz
$ tar --strip-components=1 -C ~/rpmbuild/SPECS/ --no-anchored -xvzf ~/rpmbuild/SOURCES/ceph-13.2.4.orig.tar.gz "ceph.spec"
$ sed -i 's/\.tar\.bz2/.orig.tar.gz/g'  ~/rpmbuild/SPECS/ceph.spec
$ rpmbuild --target armv7hl --with cross -ba ~/rpmbuild/SPECS/ceph.spec
```
