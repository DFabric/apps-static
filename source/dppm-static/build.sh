#!/bin/sh

wget -qO- https://github.com/DFabric/dppm/tarball/master | tar xzf -

# Prepare directories
mkdir $PACKAGE/bin
cd DFabric-dppm-*

# Install libraries
shards install

# Needed to force the link against libstdc++ on static compilation
cat >> src/dppm.cr <<EOF
require "llvm/lib_llvm"
require "llvm/enums"
EOF

crystal build --release --static --no-debug src/dppm.cr -o ../$PACKAGE/bin/dppm
strip ../$PACKAGE/bin/dppm

