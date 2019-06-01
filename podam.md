# Running Sotolito Containers with podman


## Setup
All conainers use volumes under `/var/sotolito` so this directory should be created:

```
mkdir /var/sotolito
```

Each container needs to run a setup container:

**Eg. For the nginx container**

```

# podman run --rm --name="nginxsetup"  \
     -v /var/sotolito:/var/sotolito \
     sotolitolabs-alpine-arm-nginx-setup
```
