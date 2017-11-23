#!/bin/sh

# From https://wiki.python.org/moin/BuildStatically
wget -qO- https://www.python.org/ftp/python/$ver/Python-$ver.tar.xz | tar xJf -
cd Python-$ver

./configure LDFLAGS=-static \
  --prefix=$DIR/$PACKAGE \
  --enable-optimizations \
  --enable-ipv6 \
  --with-computed-gotos \
  --with-threads \
  --with-lto \
  --without-ensurepip

cp ../Setup.local Modules/Setup.local

make -j$nproc LDFLAGS=-static LINKFORSHARED= install
