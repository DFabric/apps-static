#!/bin/sh

echo '@v3.9 http://dl-cdn.alpinelinux.org/alpine/v3.9/community' >>/etc/apk/repositories
apk add --update shards@v3.9

# Prepare directories
git clone https://github.com/DFabric/dppm
mkdir $PACKAGE/bin
cd dppm

# Install libraries
shards install
crystal spec -p

shards build --progress --release --static
mv bin ../$PACKAGE
