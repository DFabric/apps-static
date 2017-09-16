#!/bin/sh

wget -qO- https://git.gnome.org/browse/libxslt/snapshot/libxslt-$ver.tar.xz | tar xJf -
cd libxslt-$ver

touch libtoolT
ln -s /usr/include/libxml2/libxml/ libxml

./configure --prefix=$DIR/$PACKAGE
make -j$nproc install-strip

# Replace the prefix
sed -i "s|prefix=$DIR/$PACKAGE|prefix=/usr|" $DIR/$PACKAGE/bin/xslt-config

# Strip
strip $DIR/$PACKAGE/lib/lib*.so*
