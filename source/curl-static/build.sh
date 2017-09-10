#!/bin/sh

wget -qO- https://curl.haxx.se/download/curl-$ver.tar.bz2 | tar xjf -
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

make V=1 -j$nproc curl_LDFLAGS=-all-static install

# Replace the prefix
sed -i "s|prefix=$DIR/$PACKAGE|prefix=/usr|" $DIR/$PACKAGE/bin/curl-config
sed -i "s|libdir='$DIR/$PACKAGE/lib'|libdir='/usr/lib'|" $DIR/$PACKAGE/lib/libcurl.la

# Strip
strip $DIR/$PACKAGE/bin/curl
