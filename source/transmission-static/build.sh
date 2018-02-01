#!/bin/sh

wget -qO- https://github.com/transmission/transmission-releases/raw/master/transmission-$ver.tar.xz | tar xJf -
cd transmission-$ver

# https://github.com/transmission/transmission/wiki/Building-Transmission

# Fix the fact that $LDFLAGS is present after $CC, but this later don't recognize the '-all-static' argument
sed -i 's/ $LDFLAGS / -static /g' configure

./configure --prefix='/' \
  LDFLAGS=-all-static \
  --enable-utp \
  --with-inotify \
  --enable-cli

# Patch to build with libressl-dev
cd libtransmission
patch < $DIR/libressl.patch
cd ..

# Build & install to /usr/local
make -j$nproc LDFLAGS=-all-static LINKFORSHARED= DESTDIR="$DIR/$PACKAGE" install-strip
