# Build Ceph for SotolitoOs

Since the upstream ceph team does not build package 

## Install RPM build tools

```
# dnf install rpm-build rpmdevtools -y
```

*Optional* Install arm cross compile dependencies  

```
# dnf install -y binutils-arm-linux-gnu arm-none-eabi-gcc-cs-c++ gcc-c++-arm-linux-gnu gcc-c++ libtool
```

Install build dependencies

```
# dnf install -y CUnit-devel Cython boost-random cmake expat-devel fuse-devel gperf gperftools-devel java-devel jq junit keyutils-libs-devel leveldb-devel libaio-devel libbabeltrace-devel libblkid-devel libcurl-devel libibverbs-devel liboath-devel libudev-devel libuuid-devel libxml2-devel lttng-ust-devel lz4-devel nss-devel openldap-devel openssl-devel perl python3-Cython python3-devel python3-sphinx redhat-lsb-core selinux-policy-devel sharutils snappy-devel valgrind-devel xfsprogs-devel xmlstarlet yasm python-devel python-prettytable python-sphinx
```

**As a regular user**

*For this document we'll build mimic (13.2.4)*

```
$ rpmdev-setuptree
$ wget wget -O ~/rpmbuild/SOURCES/ceph-13.2.4.orig.tar.gz https://download.ceph.com/tarballs/ceph_13.2.4.orig.tar.gz https://download.ceph.com/tarballs/ceph_13.2.4.orig.tar.gz
$ tar --strip-components=1 -C ~/rpmbuild/SPECS/ --no-anchored -xvzf ~/rpmbuild/SOURCES/ceph-13.2.4.orig.tar.gz "ceph.spec"
$ sed -i 's/\.tar\.bz2/.orig.tar.gz/g'  ~/rpmbuild/SPECS/ceph.spec
$ sed -i 's/%{_python_buildid}//' ~/rpmbuild/SPECS/ceph.spec  # for this version
$ sed -i 's/make "$CEPH_MFLAGS_JOBS"/make -j7/' ~/rpmbuild/SPECS/ceph.spec  # The cubietruck can handle parallel compile
```

If compiling on the device:

Use distcc to improve compiling time:

Add this to ~/.rpmmacros

```
%_smp_mflags -j5
%configure \
  CFLAGS="${CFLAGS:-%optflags}" ; export CFLAGS ; \
  CXXFLAGS="${CXXFLAGS:-%optflags}" ; export CXXFLAGS ; \
  FFLAGS="${FFLAGS:-%optflags}" ; export FFLAGS ; \
  CCACHE_DISTCC=1; export CCACHE_DISTCC ; \
  DISTCC_HOST="host1 host2 host3 host4" ; export DISTCC_HOST ; \
  CC="ccache" ; export CC ; \
  CXX="ccache" ; export CXX ; \
  MAKEOPTS="%{_smp_mflags}" ; export MAKEOPTS ; \
  ./configure \\\
        %{?_gnu: --target=%{_target_platform}} \\\
        %{!?_gnu: --target=%{_target_platform}} \\\
        --prefix=%{_prefix} \\\
        --exec-prefix=%{_exec_prefix} \\\
        --bindir=%{_bindir} \\\
        --sbindir=%{_sbindir} \\\
        --sysconfdir=%{_sysconfdir} \\\
        --datadir=%{_datadir} \\\
        --includedir=%{_includedir} \\\
        --libdir=%{_libdir} \\\
        --libexecdir=%{_libexecdir} \\\
        --localstatedir=%{_localstatedir} \\\
        --sharedstatedir=%{_sharedstatedir} \\\
        --mandir=%{_mandir} \\\
        --infodir=%{_infodir}
```



```
$  RPM_BUILD_NCPUS=7 CEPH_MFLAGS_JOBS=7 rpmbuild -ba ~/rpmbuild/SPECS/ceph.spec
```


If cross compiling *not working*

```
$  RPM_BUILD_NCPUS=7 CEPH_MFLAGS_JOBS=7 rpmbuild --target armv7hl --with cross -ba ~/rpmbuild/SPECS/ceph.spec
