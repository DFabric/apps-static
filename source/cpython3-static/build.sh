#!/bin/sh
set -eu

# From https://wiki.python.org/moin/BuildStatically

wget -qO- https://www.python.org/ftp/python/$ver/Python-$ver.tar.xz | tar xJf -
cd Python-$ver

# Prefix is not $PACKAGE becuase Make don't like '3:''
./configure LDFLAGS=-static \
  --prefix=--prefix=$DIR/$PACKAGE \
  --disable-shared \
  --enable-optimizations \
  --enable-ipv6 \
  --enable-loadable-sqlite-extensions \
  --with-computed-gotos \
  --with-threads \
  --with-lto \
  --without-ensurepip

cp ../Setup.local Modules/Setup.local

make -j4 LDFLAGS=-static LINKFORSHARED= install
