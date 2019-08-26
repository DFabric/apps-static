#!/bin/sh

wget -qO- https://github.com/transmission/transmission-releases/raw/master/transmission-$ver.tar.xz | tar xJf -
cd transmission-$ver

# https://github.com/transmission/transmission/wiki/Building-Transmission

./configure LIBCURL_LIBS="$(pkg-config --libs --static libcurl)" \
  --prefix='/' \
  --enable-utp \
  --with-inotify \
  --enable-cli

# Build & install to /usr/local
make -j$(nproc) LDFLAGS=-all-static DESTDIR="$DIR/$PACKAGE" install-strip
