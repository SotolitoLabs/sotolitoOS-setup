# ChaverOS Enterprise

Instead of using a bash script we'll use lorax `image-composer`

## Install `image-composer`
```bash
# dnf install -y osbuild-composer composer-cli cockpit-composer lorax-templates-generic.x86_64


```
### Install elrepo to allow composer to install it to the image
```
# dnf install -y   https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm
# dnf config-manager --set-enabled elrepo --set-enabled elrepo-kernel
```

## Create blueprint

```bash

# cp /usr/share/doc/weldr-client/examples/example-custom-base.toml chaveros-live-install.toml
```
