#!/bin/sh

# Install crystal
echo http://public.portalier.com/alpine/testing >> /etc/apk/repositories
wget http://public.portalier.com/alpine/julien%40portalier.com-56dab02e.rsa.pub -O /etc/apk/keys/julien@portalier.com-56dab02e.rsa.pub
apk add --update crystal shards

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

