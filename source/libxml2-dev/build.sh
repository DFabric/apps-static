#!/bin/sh

wget -qO- ftp://xmlsoft.org/libxml2/libxml2-$ver.tar.gz | tar zxf -

cd libxml2-$ver

./configure --prefix=$DIR/$PACKAGE
make -j$(nproc) install

# Replace the prefix
sed -i "s|prefix=$DIR/$PACKAGE|prefix=/usr|" $DIR/$PACKAGE/bin/xml2-config

# Strip
strip $DIR/$PACKAGE/lib/lib*.so*
