# Running Sotolito Containers with podman


## Setup
All conainers use volumes under `/var/sotolito` so this directory should be created:

```
mkdir /var/sotolito
```

Each container needs to run a setup image:

**Eg. For the nginx container**

```

# podman run --rm --name="nginxsetup"  \
     -v /var/sotolito:/var/sotolito \
     sotolitolabs-alpine-arm-nginx-setup
```

After running this container the `nginx` image is ready to be user:

```
podman run --name="nginx" -d -p 8080:80    \
           -v /var/sotolito/vols/nginx/var:/var/ \
           -v /var/sotolito/vols/nginx/etc/nginx:/etc/nginx \
           -v /var/sotolito/vols/php-fpm/run/php-fpm/:/run/php-fpm/  \
           -v /var/sotolito/vols/php-apps/:/var/lib/nginx/html/php-apps/ \
           -e "LANG=en_US.UTF-8" \
           -e "LC_MESSAGES=POSIX" \
           -e "LANGUAGE=en_US.UTF-8" \
           -e "LC_CTYPE=en_US.UTF-8" \
           sotolitolabs-alpine-arm-nginx 
```
