#!/bin/sh

wget -qO- docs.php.net/get/php-$ver.tar.xz/from/this/mirror | tar xJf -
cd php-$ver

./configure LDFLAGS=-static PHP_LDFLAGS=-all-static LIBS=-lssh2 \
 	--prefix=$DIR/$PACKAGE \
 	--enable-static \
 	--disable-pear \
 	--enable-cgi \
 	--enable-fpm \
 	--enable-cli \
 	--enable-phpdbg \
 	--enable-inline-optimization \
 	--disable-debug \
 	--disable-rpath \
 	--with-pic \
 	--enable-bcmath \
 	  --with-bz2 \
 	--enable-calendar \
 	  --with-cdb \
 	--enable-ctype \
 	  --with-curl \
 	--enable-dom \
 	--enable-exif \
 	  --with-freetype-dir \
 	--enable-ftp \
 	--enable-gd-native-ttf \
 	  --with-gdbm \
 	  --with-iconv \
 	  --with-icu-dir=/usr \
 	--enable-json \
 	--enable-libxml \
 	--enable-mbregex \
 	--enable-mbstring=all \
 	--enable-mysqlnd \
 	  --with-mysqli=mysqlnd \
 	  --with-pdo-mysql=mysqlnd \
 	  --with-openssl \
 	  --with-pcre-regex=/usr \
 	--enable-pdo \
 	  --with-pdo-mysql=mysqlnd \
 	  --with-pdo-sqlite \
 	--enable-phar \
 	--enable-posix \
 	--enable-session \
 	--enable-shmop \
 	--enable-soap \
 	--enable-sockets \
 	  --with-sqlite3 \
 	--enable-sysvmsg \
 	--enable-sysvsem \
 	--enable-sysvshm \
 	--enable-xml \
 	--enable-xmlreader \
 	  --with-xmlrpc \
 	--enable-wddx \
 	--enable-zip \
 	  --with-zlib \
 	--without-db1 \
 	--without-db2 \
 	--without-db3 \
 	--without-qdbm \
 	--with-pdo-dblib \
 	--enable-opcache

make V=1 -j$nproc PHP_LDFLAGS=-all-static install

# Strip
strip $DIR/$PACKAGE/bin/php $DIR/$PACKAGE/bin/php-cgi $DIR/$PACKAGE/bin/phpdbg $DIR/$PACKAGE/sbin/php-fpm
