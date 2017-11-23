#!/bin/sh

wget -qO- https://github.com/libevent/libevent/releases/download/release-$ver-stable/libevent-$ver-stable.tar.gz | tar xzf -
cd libevent-$ver-stable

./configure --prefix=$DIR/$PACKAGE

make -j$nproc install-strip
