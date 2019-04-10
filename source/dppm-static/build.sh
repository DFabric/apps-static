#!/bin/sh

# Prepare directories
git clone https://github.com/DFabric/dppm
mkdir $PACKAGE/bin
cd dppm

# Install libraries
shards install
crystal spec -p

shards build --progress --release --static
mv bin ../$PACKAGE
