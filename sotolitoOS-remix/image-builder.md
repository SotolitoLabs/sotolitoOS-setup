# ChaverOS Enterprise

Instead of using a bash script we'll use lorax `image-composer`

## Install `image-composer`
```console
# dnf install -y osbuild-composer composer-cli cockpit-composer lorax-templates-generic.x86_64
```

### Install elrepo to allow composer to install it to the image
```console
# dnf install -y   https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm
# dnf config-manager --set-enabled elrepo --set-enabled elrepo-kernel
```

## Create the blueprint

```console
cat chaveros-live-install.toml 
name = "ChaverOS-base"
description = "ChaverOS Enterprise Base System"
version = "0.0.1"
arch = x86_64

[[packages]]
name = "bash"
version = "*"

[customizations]
hostname = "chaverOS"

[[customizations.user]]
name = "chaveros"
password = "prueba123"
description = "ChaverOS User"
home = "/home/chaveros/"
shell = "/usr/bin/bash"
groups = ["chaveros", "wheel"]

[[customizations.group]]
name = "chaveros"
```

## Create Image

### Branding

```console
# mkdir /usr/share/lorax/product
# cp anaconda/branding/product/* /usr/share/lorax/product/.
```

## Create Blueprint

```console
# cp /usr/share/doc/weldr-client/examples/example-custom-base.toml chaveros-live-install.toml
# add personalizaton
# composer-cli blueprints push chaveros-live-install.toml
```

## List Type of Images (optional)

```console
# composer-cli compose types
...
*image-installer*
...
```

## Create Image

```console
# composer-cli compose start ChaverOS-base image-installer
```

### Verify image creation

```console
# composer-cli compose status
```


### Check logs
```console
composer-cli compose logs <image UUID>
```

## Get the image

```console
# composer-cli compose image <image UUID>
```

# References
* https://weldr.io/lorax/lorax-composer/composer-cli.html
* https://weldr.io/lorax/lorax-composer/product-images.html
