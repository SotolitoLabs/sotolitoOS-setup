%define debug_package %{nil}
%define product_family SotolitoOS Linux
%define variant_titlecase Server
%define variant_lowercase server
%define targetdir %{_target_cpu}
%ifarch x86_64
%define release_name Gin
%else
%define release_name Gin-AltArch
%endif
%ifarch aarch64
%define dist_suffix .a
%endif
%ifarch ppc ppc64 ppc64le
%define dist_suffix .p
%define tuned_profile :server
%endif
%ifarch ppc64le
%if "%{dist}" == ".el7a"
%define dist_suffix .p9
%define targetdir power9
%endif
%endif
%ifarch %{ix86}
%define dist_suffix .i
%endif
%define base_release_version 7
%define full_release_version 7
%define dist_release_version 7
%define upstream_rel_long 7.0-0
%define upstream_rel 7.0
%define centos_rel 6.1810
#define beta Beta
%define dist .el%{dist_release_version}.sotolitoos%{?dist_suffix}

%ifarch %{arm}
Name:           sotolitoos-userland-release
%else
Name:           sotolitoos-release
%endif
Version:        %{base_release_version}
Release:        %{centos_rel}.3%{?dist}
Summary:        %{product_family} release file
Group:          System Environment/Base
License:        GPLv2
Requires(post): coreutils, grep
%ifarch %{arm}
Requires:       extlinux-bootloader
%endif
Provides:       sotolitoos-release = %{version}-%{release}
Provides:       sotolitoos-release(upstream) = %{upstream_rel}
Source0:        sotolitoos-release-%{base_release_version}-%{centos_rel}.tar.gz
#Source1:        85-display-manager.preset
#Source2:        90-default.preset
#Source99:       update-boot
#Source100:      rootfs-expand

%description
%{product_family} release files

%prep
%setup -q -n sotolitoos-release-%{base_release_version}

%build
echo OK

%install
rm -rf %{buildroot}

# create /etc
mkdir -p %{buildroot}/etc

# create /etc/system-release and /etc/redhat-release
echo "%{product_family} release %{full_release_version}.%{centos_rel} (%{release_name}) " > %{buildroot}/etc/sotolitoos-release
echo "Derived from Red Hat Enterprise Linux %{upstream_rel} (Source) and CentOS" > %{buildroot}/etc/sotolitoos-release-upstream

# create /etc/os-release
cat << EOF >>%{buildroot}/etc/sotolito-os-release
NAME="%{product_family}"
VERSION="%{full_release_version} (%{release_name})"
ID="sotolito"
ID_LIKE="rhel fedora"
VERSION_ID="%{full_release_version}"
PRETTY_NAME="%{product_family} %{full_release_version} (%{release_name})"
ANSI_COLOR="0;31"
CPE_NAME="cpe:/o:sotolitolabs:sotolitoos:7%{?tuned_profile}"
HOME_URL="https://www.sotolitolabs.com/"
BUG_REPORT_URL="https://bugs.sotolitolabs.com/"

CENTOS_MANTISBT_PROJECT="CentOS-7"
CENTOS_MANTISBT_PROJECT_VERSION="7"
REDHAT_SUPPORT_PRODUCT="centos"
REDHAT_SUPPORT_PRODUCT_VERSION="7"

EOF

pushd %{targetdir}
# copy GPG keys
mkdir -p -m 755 %{buildroot}/etc/pki/rpm-gpg

# copy yum repos
mkdir -p -m 755 %{buildroot}/etc/yum.repos.d
install -m 644 SotolitoOS.repo %{buildroot}/etc/yum.repos.d

%ifarch x86_64
install -m 644 elrepo.repo %{buildroot}/etc/yum.repos.d
install -m 644 RPM-GPG-KEY-elrepo.org %{buildroot}/etc/pki/rpm-gpg
%endif


popd


# use unbranded datadir
#mkdir -p -m 755 %{buildroot}/%{_datadir}/centos-release
#ln -s centos-release %{buildroot}/%{_datadir}/redhat-release
#install -m 644 EULA %{buildroot}/%{_datadir}/centos-release

# use unbranded docdir
#mkdir -p -m 755 %{buildroot}/%{_docdir}/centos-release
#ln -s centos-release %{buildroot}/%{_docdir}/redhat-release
#install -m 644 GPL %{buildroot}/%{_docdir}/centos-release
#install -m 644 Contributors %{buildroot}/%{_docdir}/centos-release

# copy systemd presets
#mkdir -p %{buildroot}%{_prefix}/lib/systemd/system-preset/
#install -m 0644 %{SOURCE1} %{buildroot}%{_prefix}/lib/systemd/system-preset/
#install -m 0644 %{SOURCE2} %{buildroot}%{_prefix}/lib/systemd/system-preset/

%ifarch %{arm}
# Install armhfp specific tools
#mkdir -p %{buildroot}/%{_bindir}/
#install -m 0755 %{SOURCE99} %{buildroot}%{_bindir}/
#install -m 0755 %{SOURCE100} %{buildroot}%{_bindir}/
%endif

%posttrans
%ifarch %{arm}
#if [ -e /usr/local/bin/rootfs-expand ];then
#rm -f /usr/local/bin/rootfs-expand
#fi
%endif


# Update branding
%post
rm /etc/os-release /etc/redhat-release /etc/system-release /etc/centos-release
ln -sf /etc/sotolitoos-release /etc/redhat-release
ln -sf /etc/sotolitoos-release /etc/system-release
ln -sf /etc/sotolitoos-release /etc/centos-release
ln -sf /etc/sotolito-os-release /etc/os-release
# write cpe to /etc/system/release-cpe
echo "cpe:/o:sotolitolabs:sotolitoos:7" > /etc/system-release-cpe
# create /etc/issue and /etc/issue.net
echo '\S' > /etc/issue
echo 'Kernel \r on an \m' >> /etc/issue
cp /etc/issue /etc/issue.net
echo >> /etc/issue
# set up the dist tag macros
cat >> /etc/rpm/macros.dist << EOF
# dist macros.

%%centos_ver %{base_release_version}
%%centos %{base_release_version}
%%rhel %{base_release_version}
%%dist .el7
%%el%{base_release_version} 1
EOF



/usr/bin/uname -m | grep -q 'x86_64'  && echo 'sotolito' >/etc/yum/vars/contentdir || echo 'altarch' > /etc/yum/vars/contentdir


%clean
rm -rf %{buildroot}

%files
%defattr(0644,root,root,0755)
%config /etc/sotolitoos-release
%config /etc/sotolitoos-release-upstream
%config /etc/sotolito-os-release

#TODO /etc/pki/rpm-gpg/
%config(noreplace) /etc/yum.repos.d/*

%ifarch x86_64
%config(noreplace) /etc/pki/rpm-gpg/RPM-GPG-KEY-elrepo.org
%endif
#/etc/rpm/macros.dist
%ifarch %{arm}
#%attr(0755,root,root) %{_bindir}/update-boot
#%attr(0755,root,root) %{_bindir}/rootfs-expand
%endif

%changelog
* Mon Feb 17 2020 Iván Chavero <ichavero@chavero.com.mx>
- Fix repo file names 

* Sun Dec 22 2019 Iván Chavero <ichavero@chavero.com.mx>
- Update from Centos 8

* Fri Sep 13 2019 Iván Chavero <ichavero@chavero.com.mx>
- First SotolitoOS release
- Update Centos brand files
- Add elrepo yum repository for x86_64

* Fri Nov 23 2018 Pablo Greco <pablo@fliagreco.com.ar>
- Update to 7.6
- Fix vault repos

* Mon Oct  1 2018 Anssi Johansson <avij@centosproject.org>
- Point AltArch URLs to mirrorlist.c.o instead of mirror.c.o

* Thu Aug  9 2018 Pablo Greco <pablo@fliagreco.com.ar>
- Enable ostree-remount in presets
- Include power9 as a separate ppc64le arch

* Fri Aug  3 2018 Pablo Greco <pablo@fliagreco.com.ar>
- Unified tarball for all arches, so it can be built from the same src.rpm

* Thu Aug  2 2018 Pablo Greco <pablo@fliagreco.com.ar>
- Sync version and fixes with centos-release
- Unified spec for all arches

* Thu Aug  2 2018 Johnny Hughes <johnny@centos.org>
- Post Trans for contentdir

* Fri May  4 2018 Pablo Greco <pablo@fliagreco.com.ar>
- armhfp: Require extlinux-bootloader now that update-boot was obsoleted

* Wed Apr 11 2018 Johnny Hughes <johnny@centos.org>
- Bump Release for 1804

* Wed Mar 21 2018 Pablo Greco <pablo@fliagreco.com.ar>
- armhfp: Update rootfs-expand to detect rootfs
- armhfp: Obsolete update-boot
- armhfp: Remove old versions of rootfs-expand

* Thu Dec 28 2017 Fabian Arrotin <arrfab@centos.org>
- armhfp: Fixed the post scriptlet to detect correctly rpi2/rpi3 with 4.9 kernel

* Wed Aug 30 2017 Johnny Hughes <johnny@centos.org>
- Bump Release for 1708

* Mon Feb 27 2017 Fabian Arrotin <arrfab@centos.org>
- armhfp: Added rootfs-expand and update-boot tools for armhfp

* Tue Nov 29 2016 Johnny Hughes <johnny@centos.org>
- Bump Release for 1611

* Mon Oct 24 2016 Fabian Arrotin <arrfab@centos.org>
- armhfp: Using a new kvariant yum var to point to correct kernel repo path

* Wed Dec 2 2015 Fabian Arrotin <arrfab@centos.org>
- armhfp: Fixed the definitive altarch path for altarch/armhfp

* Tue Dec  1 2015 Johnny Hughes <johnny@centos.org>
- Bump Release for 1511
- Add CentOS-Media.repo and put CentOS-CR.repo in the
  tarball, then removed patch1000 

* Mon Nov 30 2015 Fabian Arrotin <arrfab@centos.org>
- armhfp: Defaulting to normal repositories now (release approaching)

* Sat Nov 28 2015 Fabian Arrotin <arrfab@centos.org>
- armhfp: Overriding the releasever yum var, as pkg name isn't centos-release

* Fri Nov 27 2015 Fabian Arrotin <arrfab@centos.org>
- armhfp: initial release for the AltArch armhfp userland

* Tue Mar 31 2015 Karanbir Singh <kbsingh@centos.org>
- rework upstream communication
- re-establish redhat-release as a symlink from centos-release

* Fri Mar 27 2015 Karanbir Singh <kbsingh@centos.org>
- dont auto enable the initial-setup tui mode

* Thu Mar 19 2015 Karanbir Singh <kbsingh@centos.org>
- Bump Release for 1503 
- add ABRT specific content to os-release
- split redhat-release from centos-release

* Tue Feb 17 2015 Karanbir Singh <kbsingh@centos.org>
- Include the CR repo for upcoming 7.1 release ( and beyond )

* Thu Aug 21 2014 Karanbir Singh <kbsingh@centos.org>
- add a yum var to route mirrorlist accurately
- add CentOS-fastrack repo
- Trim the CentOS-Debug-7 key
- rename the Debug repo to base-debug so yum-utils can consume easier

* Tue Jul 15 2014 Karanbir Singh <kbsingh@centos.org>
- add CentOS-7 Debug rpm key

* Fri Jul 4 2014 Karanbir Singh <kbsingh@centos.org>
- Roll in the final name change conversation results
- Stage for release content
- Add yum repos
- Add distro keys ( incomplete )

* Mon Jun 30 2014 Karanbir Singh <kbsingh@centos.org>
- add a macro to macros.dist to indicate just centos as well 

* Tue Jun 24 2014 Karanbir Singh <kbsingh@centos.org> 
- Trial run for CentOS DateStamp release
- Add stubs for the yum repos
- fix os-release to only have one ID_LIKE ( Avij #7171)
- make the yum repo definitions be config noreplace ( Trevor )

* Tue Jun 17 2014 Karanbir Singh <kbsingh@centos.org> 7.0.el7.0.140617.3
- rebuild for 2014-06-17 pub qa release
- ensure we get the right cpe info
- ensure centos-release is trackable

* Sat Jun 14 2014 Karanbir Singh <kbsingh@centos.org> 7.0.el7.0.140614.2
- prep for public QA release tag as broken

* Fri Jun 13 2014 Karanbir Singh <kbsingh@centos.org> 7-0.el7
- initial setup for centos-rc

