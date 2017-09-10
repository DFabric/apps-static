#!/bin/sh

year=$(regexlook -w '(?<=").*(?=-[09])' https://sqlite.org/releaselog/$(printf "$ver" | tr . _).html)
id=$(regexlook -w "(?<=key=').*(?='.*$ver)" https://sqlite.org/chronology.html)

wget -qO- https://sqlite.org/$year/sqlite-autoconf-$id.tar.gz | tar zxf -

cd sqlite-autoconf-$id

./configure --prefix=$DIR/$PACKAGE \
  --enable-static \
  --enable-shared \
  LDFLAGS=-static \
  CFLAGS="-DSQLITE_ENABLE_FTS3=1 -DSQLITE_ENABLE_COLUMN_METADATA=1 -DSQLITE_ENABLE_FTS3_PARENTHESIS -DSQLITE_SECURE_DELETE -DSQLITE_ENABLE_UNLOCK_NOTIFY -DSQLITE_ENABLE_RTREE=1 -DSQLITE_USE_URI -DSQLITE_ENABLE_DBSTAT_VTAB -DSQLITE_ENABLE_JSON1 -Iext/fts3"

# Build & install to /usr/local
make -j$nproc LDFLAGS=-static install

# Replace the prefix
sed -i "s|prefix=$DIR/$PACKAGE|prefix=/usr|" $DIR/$PACKAGE/lib/pkgconfig/sqlite3.pc
sed -i "s|libdir='$DIR/$PACKAGE/lib'|libdir='/usr/lib'|" $DIR/$PACKAGE/lib/libsqlite3.la

# Strip
strip $DIR/$PACKAGE/bin/sqlite3
