#!/bin/sh

wget -qO- https://download.qemu-project.org/qemu-$ver.tar.xz | tar xJf -

cd qemu-$ver

./configure --static --prefix=$DIR/$PACKAGE \
  --extra-cflags=-DCONFIG_RTNETLINK \
  --target-list=arm-linux-user,aarch64-linux-user

# Apply patches from ALpine on the qemu source, mainly musl related
# https://git.alpinelinux.org/cgit/aports/tree/main/qemu
cd linux-user
patch < $DIR/0006-linux-user-signal.c-define-__SIGRTMIN-MAX-for-non-GN.patch
patch < $DIR/fix-sigevent-and-sigval_t.patch
patch < $DIR/fix-sockios-header.patch
patch < $DIR/musl-F_SHLCK-and-F_EXLCK.patch

cd host/aarch64
patch < $DIR/0001-linux-user-fix-build-with-musl-on-aarch64.patch

cd ../../..
make -j$nproc install
