#!/bin/bash

# Generate product.img for the anaconda installer
cd product
find . | cpio -c -o | gzip -9cv > ../product.img
