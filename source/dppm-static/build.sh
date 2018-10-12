#!/bin/sh

wget -qO- https://github.com/DFabric/dppm/tarball/master | tar xzf -

# Prepare directories
mkdir $PACKAGE/bin
cd DFabric-dppm-*

# Install libraries
shards install

crystal build --progress --threads $nproc --release --static --link-flags -lunwind --no-debug src/dppm.cr -o ../$PACKAGE/bin/dppm
strip ../$PACKAGE/bin/dppm

