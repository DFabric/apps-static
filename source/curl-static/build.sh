#!/bin/sh

wget -qO- https://curl.haxx.se/download/curl-$ver.tar.xz | tar xJf -
cd curl-$ver

./configure LDFLAGS=-static PKG_CONFIG='pkg-config --static' --prefix=$DIR/$PACKAGE \
  --disable-shared \
  --enable-static \
  --enable-ipv6 \
  --enable-unix-sockets \
  --without-libidn \
  --without-libidn2 \
  --disable-ldap \
  --with-pic

make V=1 -j$nproc curl_LDFLAGS=-all-static install-strip
