#!/bin/sh

wget -qO- https://git.gnome.org/browse/libxml2/snapshot/libxml2-$ver.tar.xz | tar xJf -
cd libxml2-$ver

./configure --prefix=$DIR/$PACKAGE
make -j$nproc install-strip

# Replace the prefix
sed -i "s|prefix=$DIR/$PACKAGE|prefix=/usr|" $DIR/$PACKAGE/bin/xml2-config
