#!/bin/sh
set -eu

# From https://wiki.python.org/moin/BuildStatically
wget -qO- https://www.python.org/ftp/python/$ver/Python-$ver.tar.xz | tar xJf -
cd Python-$ver

# Prefix is not $PACKAGE becuase Make don't like '3:''
./configure LDFLAGS=-static \
  --prefix=$DIR/$PACKAGE \
  --disable-shared \
  --enable-optimizations \
  --enable-ipv6 \
  --with-computed-gotos \
  --with-threads \
  --with-lto \
  --without-ensurepip

cp ../Setup.local Modules/Setup.local

make -j$nproc LDFLAGS=-static LINKFORSHARED= install

# Replace the prefix
sed -i "s|prefix_build=\"$DIR/$PACKAGE\"|prefix_build=/usr|" $DIR/$PACKAGE/bin/python3-config
