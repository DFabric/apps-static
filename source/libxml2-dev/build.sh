#!/bin/sh

wget -qO- ftp://xmlsoft.org/libxml2/libxml2-$ver.tar.gz | tar zxf -

cd libxml2-$ver

./configure --prefix=$DIR/$PACKAGE
make -j$(nproc) install

strip $DIR/$PACKAGE/lib/*.so* $DIR/$PACKAGE/lib/*.a

# Needed to build the index
ranlib $DIR/$PACKAGE/lib/*.a
