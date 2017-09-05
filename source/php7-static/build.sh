#!/bin/sh

# Alpine dependencies
wget -qO- docs.php.net/get/php-$ver.tar.xz/from/this/mirror | tar xJf -

cd php-$ver
# ranlib /usr/lib/libxml
# zlib.net/zlib-1.2.11.tar.gz

# --disable-all
./configure --prefix=$DIR/$PACKAGE LDFLAGS=-static \
 	--enable-static \
 	--disable-pear \
 	--disable-shared \
 		--disable-cli \
 		--enable-cgi \
 		--enable-fpm \
 		--enable-cli \
 		--enable-phpdbg \
 	--disable-debug \
 	--disable-rpath \
 	--with-pic \
 	--enable-bcmath \
 	  --with-bz2 \
 	--enable-calendar \
 	  --with-cdb \
 	--enable-ctype \
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
 	--without-db1 \
 	--without-db2 \
 	--without-db3 \
 	--without-qdbm \
 	--with-pdo-dblib \
 	--enable-opcache=no

# Add static compilation
sed -i "s/-export-dynamic/-all-static -export-dynamic/g" Makefile

make -j$(nproc) LDFLAGS=-static install

strip $DIR/$PACKAGE/bin/php $DIR/$PACKAGE/bin/php-cgi $DIR/$PACKAGE/bin/phpdbg $DIR/$PACKAGE/sbin/php-fpm
