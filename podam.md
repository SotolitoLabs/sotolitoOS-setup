# Running Sotolito Containers with podman


## Setup
All conainers use volumes under `/var/sotolito`

Each container needs to run a setup container:

**Eg. For the nginx container**

```

# docker run --rm --name="nginxsetup"  \
           -v /var/sotolito:/var/sotolito \
sotolitolabs-alpine-arm-nginx-setup
```
