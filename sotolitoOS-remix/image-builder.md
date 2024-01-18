# ChaverOS Enterprise

Instead of using a bash script we'll use lorax `image-composer`

## Install `image-composer`
```shell
# dnf install -y osbuild-composer composer-cli cockpit-composer lorax-templates-generic.x86_64


```
### Install elrepo to allow composer to install it to the image
```bash
# dnf install -y   https://www.elrepo.org/elrepo-release-9.el9.elrepo.noarch.rpm
# dnf config-manager --set-enabled elrepo --set-enabled elrepo-kernel
```

## Create Image

### Branding

```bash
# mkdir /usr/share/lorax/product
# cp anaconda/branding/product/* /usr/share/lorax/product/.
```

## Create Blueprint

```bash
# cp /usr/share/doc/weldr-client/examples/example-custom-base.toml chaveros-live-install.toml
# add personalizaton
# composer-cli blueprints push chaveros-live-install.toml
```

## List Type of Images (optional)

```bash
# composer-cli compose types
...
*image-installer*
...
```

## Create Image

```bash
# composer-cli compose start ChaverOS-base image-installer
```

# References
* https://weldr.io/lorax/lorax-composer/composer-cli.html
* https://weldr.io/lorax/lorax-composer/product-images.html
