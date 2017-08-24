#!/bin/sh

wget -qO- https://www.kernel.org/pub/software/scm/git/git-$ver.tar.gz | tar zxf -

cd git-$ver

./configure --prefix=$DIR/$PACKAGE \
  LDFLAGS=-static \
  NO_GETTEXT=YesPlease \
  NO_SVN_TESTS=YesPlease \
  NO_REGEX=YesPlease \
  USE_LIBPCRE2=YesPlease \
  NO_NSEC=YesPlease \
  NO_SYS_POLL_H=1

# Build & install to /usr/local
make -j4 LDFLAGS=-static LINKFORSHARED= install

# Strip
strip $DIR/$PACKAGE/bin/* 2>/dev/null || true
strip $DIR/$PACKAGE/libexec/git-core/* 2>/dev/null || true
