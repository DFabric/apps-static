#!/bin/sh

# From https://wiki.python.org/moin/BuildStatically
wget -qO- https://www.python.org/ftp/python/$ver/Python-$ver.tar.xz | tar xJf -
cd Python-$ver

./configure LDFLAGS=-static \
  --prefix='/' \
  --enable-optimizations \
  --enable-ipv6 \
  --with-computed-gotos \
  --with-threads \
  --with-lto \
  --without-ensurepip

cp ../Setup.local Modules/Setup.local
[ "$ARCH" = arm64 ] && sed -i '/-DASM/d' Modules/Setup.local

make -j$nproc LDFLAGS=-static LINKFORSHARED= DESTDIR="$DIR/$PACKAGE" install
