#!/bin/sh

# Prepare directories
git clone https://github.com/DFabric/dppm
mkdir $PACKAGE/bin
cd dppm

# Install libraries
shards install

crystal build --progress --threads $nproc --release --static --link-flags -lunwind --no-debug src/dppm.cr -o ../$PACKAGE/bin/dppm
strip ../$PACKAGE/bin/dppm

