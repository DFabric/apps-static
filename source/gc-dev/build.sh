#!/bin/sh

wget -qO- https://github.com/ivmai/bdwgc/releases/download/v$ver/gc-$ver.tar.gz | tar xzf -
cd gc-$ver

./configure \
	--prefix='/' \
	CFLAGS="-D_GNU_SOURCE -DNO_GETCONTEXT -DUSE_MMAP -DHAVE_DL_ITERATE_PHDR -DIGNORE_DYNAMIC_LOADING" \
	--enable-cplusplus \
	--disable-parallel-mark \
	--enable-munmap

make -j$nproc DESTDIR="$DIR/$PACKAGE" install-strip
