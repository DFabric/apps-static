#!/bin/sh

wget -qO- https://www.kernel.org/pub/software/scm/git/git-$ver.tar.xz | tar xJf -
cd git-$ver

./configure \
  --prefix='/' \
  --without-tcltk \
  NO_GETTEXT=YesPlease \
  NO_SVN_TESTS=YesPlease \
  NO_REGEX=YesPlease \
  USE_LIBPCRE2=YesPlease \
  NO_SYS_POLL_H=1

# Build & install
make -j$(nproc) LDFLAGS=-static DESTDIR="$DIR/$PACKAGE" install strip
