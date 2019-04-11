#!/bin/sh

# https://dev.minetest.net/Compiling_Minetest
wget -qO- https://github.com/minetest/minetest/archive/$ver.tar.gz | tar xzf -

cd minetest-$ver

# Build
cmake -DENABLE_CURL=0 \
      -DENABLE_GETTEXT=0 \
      -DBUILD_CLIENT=0 \
      -DBUILD_SERVER=1 \
      -DENABLE_SYSTEM_JSONCPP=1 \
      -DENABLE_LUAJIT=1 \
      -DCMAKE_EXE_LINKER_FLAGS=-static

make -j$(nproc) DESTDIR="$DIR/$PACKAGE"
mv bin games builtin $DIR/$PACKAGE
