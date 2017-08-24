#!/bin/sh

wget -qO- http://download.icu-project.org/files/icu4c/$ver/icu4c-$(printf "$ver" | tr . _)-src.tgz | tar zxf -

cd icu/source
./configure --enable-static --disable-samples --prefix=$DIR/$PACKAGE

# Fix xlocale .h not found
ln -s /usr/include/locale.h /usr/include/xlocale.h

# Build & install to /usr/local
make -j4 install

# Strip
strip $DIR/$PACKAGE/lib/lib*.*
