#!/bin/sh

wget -qO- https://downloads.sourceforge.net/project/libpng/zlib/$ver/zlib-$ver.tar.xz | tar xJf -
cd zlib-$ver

./configure --static --prefix=$DIR/$PACKAGE

make -j$nproc install

# Replace the prefix
sed -i "s|prefix=$DIR/$PACKAGE|prefix=/usr|" $DIR/$PACKAGE/lib/pkgconfig/zlib.pc
