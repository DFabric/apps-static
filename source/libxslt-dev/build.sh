#!/bin/sh

wget -qO- ftp://xmlsoft.org/libxslt/libxslt-$ver.tar.gz | tar zxf -

cd libxslt-$ver

touch libtoolT
ln -s /usr/include/libxml2/libxml/ libxml
./configure --prefix=$DIR/$PACKAGE
make -j4 install

strip $DIR/$PACKAGE/lib/*.so* $DIR/$PACKAGE/lib/*.a
