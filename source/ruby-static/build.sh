#!/bin/sh

wget -qO- https://cache.ruby-lang.org/pub/ruby/${ver%.*}/ruby-$ver.tar.xz | tar xJf -

cd ruby-$ver

# -fomit-frame-pointer makes ruby segfault, see gentoo bug #150413
# In many places aliasing rules are broken; play it safe
# as it's risky with newer compilers to leave it as it is.
export CFLAGS="-fno-omit-frame-pointer -fno-strict-aliasing"
export CPPFLAGS="-fno-omit-frame-pointer -fno-strict-aliasing"

# ruby saves path to install. we want use $PATH
export INSTALL=install

# the configure script does not detect isnan/isinf as macros
export ac_cv_func_isnan=yes
export ac_cv_func_isinf=yes

./configure \
  --prefix='/' \
  --with-static-linked-ext \
  --enable-static \
  --enable-pthread \
  --disable-shared \
  --disable-install-doc \
  --disable-rpath \
  --with-gdbm

make -j$nproc DESTDIR="$DIR/$PACKAGE" install
