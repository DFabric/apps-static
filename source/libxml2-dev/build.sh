#!/bin/sh

wget -qO- ftp://xmlsoft.org/libxml2/libxml2-$ver.tar.gz | tar zxf -

cd libxml2-$ver

./configure --prefix='/'
make -j$nproc DESTDIR="$DIR/$PACKAGE" install-strip
