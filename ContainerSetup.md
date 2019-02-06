## Sotolito OS Container Setup

This document details the initial container setup for a Sotolito OS appliance.

### Preflight

Clone the github repo:

```
# git clone https://github.com/SotolitoLabs/moximo-containers.git
# cd moximo-containers
```


### Setup mariadb

```
# cd mariadb
# ./build
# ./runsetup
# ./runmaria

```

### Setup PHP

Sotolito OS containers use php-fpm

#### Setup php-fpm


```
# cd php-fpm-setup
# ./build
# ./runsetup
# cd ../php-fpm
# ./build
# ./run
```

### Setup Web server

Currently the only web server supported is nginx.

#### Setup nginx

Build and run the setup image.

```
# cd nginx-setup
# ./build
# ./runsetup

```

Build and run the nginx image.

```
# cd nginx
# ./build
# ./runnginx

```
