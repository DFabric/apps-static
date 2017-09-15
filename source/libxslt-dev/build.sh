#!/bin/sh

wget -qO- ftp://xmlsoft.org/libxml2/libxslt-$ver.tar.gz | tar zxf -
cd libxslt-$ver

touch libtoolT
ln -s /usr/include/libxml2/libxml/ libxml

./configure --prefix=$DIR/$PACKAGE
make -j$nproc install-strip

# Replace the prefix
sed -i "s|prefix=$DIR/$PACKAGE|prefix=/usr|" $DIR/$PACKAGE/bin/xslt-config

# Strip
strip $DIR/$PACKAGE/lib/lib*.so*
