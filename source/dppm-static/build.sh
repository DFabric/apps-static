#!/bin/sh

# Prepare directories
git clone https://github.com/DFabric/dppm
mkdir $PACKAGE/bin
cd dppm

# Install libraries
shards install
crystal spec -p

crystal build --progress --threads $(nproc) --release --static --no-debug src/dppm.cr -o ../$PACKAGE/bin/dppm
strip ../$PACKAGE/bin/dppm

