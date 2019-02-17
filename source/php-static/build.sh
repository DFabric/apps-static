#!/bin/sh

wget -qO- https://secure.php.net/get/php-$ver.tar.xz/from/this/mirror | tar xJf -
cd php-$ver

ln -s /usr/include/libxml2/libxml/ /usr/include/libxml

./configure LDFLAGS=-static PHP_LDFLAGS=-all-static \
	--prefix='/' \
	--enable-static \
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
	--enable-ftp \
	--with-gd \
	  --with-freetype-dir \
	  --disable-gd-jis-conv \
	  --with-jpeg-dir \
	  --with-png-dir \
	--with-gdbm \
	--with-iconv \
	--with-icu-dir=/usr \
	--enable-json \
	--enable-mbstring=all \
	--enable-mysqlnd \
	  --with-mysqli=mysqlnd \
	  --with-pdo-mysql=mysqlnd \
	  --with-openssl \
	  --with-pcre-regex \
	--enable-pcntl \
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

make -j$(nproc) INSTALL_ROOT="$DIR/$PACKAGE" PHP_LDFLAGS=-all-static
make -j$(nproc) INSTALL_ROOT="$DIR/$PACKAGE" install

# Strip
strip $DIR/$PACKAGE/bin/php $DIR/$PACKAGE/bin/php-cgi $DIR/$PACKAGE/bin/phpdbg $DIR/$PACKAGE/sbin/php-fpm
