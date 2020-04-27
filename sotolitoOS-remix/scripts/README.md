== Create SotolitoOS ISO

The `create-iso.sh` script downloads the CentOS 8 stream ISO
and modifies it with: packages, kicksart files and branding
to get the SotolitoOS Enterprise distribution.

To create the SotolitoOS ISO Run:

```
./create-iso.sh generic 2>&1 | tee log-sotolito.log
```

=== Current SotolitoOS Features

- Based on CentOS 8 Stream
- Preconfigure elrepo repository
- Pre-loaded Ansible Hardening playbooks with Security Technical Implementation Guide (STIG)
- Update to elrepo kernel-ml 5.6.2
- Cockpit web manager


TODO: 
- Update kickstart files for automatic installations
- Change instalation workflow to use lorax
