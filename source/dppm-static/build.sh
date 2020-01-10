#!/bin/sh

# Get old shards to avoid memory exhaustion of the new one
wget -qO- https://github.com/crystal-lang/crystal/releases/download/0.31.1/crystal-0.31.1-1-linux-x86_64.tar.gz | tar -zxf -
mv crystal-0.31.1-1/lib/crystal/bin/shards /usr/local/bin
rm -rf crystal-0.31.1-1

# Prepare directories
git clone https://github.com/DFabric/dppm
mkdir $PACKAGE/bin
cd dppm

# Install libraries
shards install --production
crystal spec -p -Dallow_root

shards build --progress --release --production --static
mv bin ../$PACKAGE
