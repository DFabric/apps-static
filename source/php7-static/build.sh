#!/bin/sh

# Alpine dependencies
wget -qO- docs.php.net/get/php-$ver.tar.xz/from/this/mirror | tar xJf -

cd php-$ver
# ranlib /usr/lib/libxml
# zlib.net/zlib-1.2.11.tar.gz

# --disable-all
./configure --prefix=$DIR/$PACKAGE LDFLAGS=-static \
	--enable-static=yes \
	--disable-xml \
	--disable-libxml \
	--disable-simplexml \
	--disable-xmlreader \
	--disable-xmlwriter \
	--disable-dom \
	--disable-pear \
	--disable-shared \
		--enable-cli \
		--enable-fpm \
		--enable-phpdbg \
	--disable-debug \
	--disable-rpath \
	--with-pic \
	--enable-bcmath \
	  --with-bz2 \
	--enable-calendar \
	  --with-cdb \
	--enable-ctype \
	--enable-exif \
	  --with-freetype-dir \
	--enable-ftp \
	--enable-gd-native-ttf \
	  --with-gdbm \
	  --with-gmp \
	  --with-iconv \
		--with-icu-dir=/usr \
	  --with-imap-ssl \
	--enable-json \
	--enable-mbregex \
	--enable-mbstring=all \
	--enable-phar \
	  --with-png-dir \
	--enable-posix \
	--enable-session \
	--enable-shmop \
	--enable-sockets \
	  --with-sqlite3 \
	--enable-sysvmsg \
	--enable-sysvsem \
	--enable-sysvshm \
	--without-db1 \
	--without-db2 \
	--without-db3 \
	--without-qdbm \
	--with-pdo-dblib \
	--enable-opcache=no

# Full configure
 <<EOF
 #!/bin/sh
 ./configure --prefix=$DIR/$PACKAGE LDFLAGS=-static \
 	--enable-static \
 	--disable-shared \
 		--disable-cli \
 		--enable-cgi \
 		--enable-cli \
 		--with-pear \
 		--with-readline \
 		--enable-phpdbg \
 	--disable-debug \
 	--disable-rpath \
 	--with-pic \
 	--enable-bcmath \
 	  --with-bz2 \
 	--enable-calendar \
 	  --with-cdb \
 	--enable-ctype \
 	  --with-curl \
 	--enable-dba \
 	  --with-db4 \
 	--enable-dom \
 	  --with-enchant \
 	--enable-exif \
 	  --with-freetype-dir \
 	--enable-ftp \
 	  --with-gd \
 	--enable-gd-native-ttf \
 	  --with-gdbm \
 	  --with-gettext \
 	  --with-gmp \
 	  --with-iconv \
 	  --with-icu-dir=/usr \
 	  --with-imap \
 	  --with-imap-ssl \
 	--enable-intl \
 	  --with-jpeg-dir \
 	--enable-json \
 	  --with-ldap \
 	--enable-libxml \
 	--enable-mbregex \
 	--enable-mbstring=all \
 	  --with-mcrypt \
 	--enable-mysqlnd \
 	  --with-mysqli=mysqlnd \
 		--with-pdo-mysql=mysqlnd \
 	  --with-openssl \
 	  --with-pcre-regex=/usr \
 	--enable-pcntl \
 	--enable-pdo \
 	  --with-pdo-mysql=mysqlnd \
 	  --with-pdo-odbc=unixODBC,/usr \
 	  --with-pdo-pgsql \
 	  --with-pdo-sqlite \
 	  --with-pgsql \
 	--enable-phar \
 	  --with-png-dir \
 	--enable-posix \
 	  --with-pspell \
 	--enable-session \
 	--enable-shmop \
 	  --with-snmp \
 	--enable-soap \
 	--enable-sockets \
 	  --with-sqlite3 \
 	--enable-sysvmsg \
 	--enable-sysvsem \
 	--enable-sysvshm \
 	  --with-unixODBC=/usr \
 	--enable-xml \
 	--enable-xmlreader \
 	  --with-xmlrpc \
 	  --with-xsl \
 	--enable-wddx \
 	--enable-zip \
 	  --with-zlib \
 	--without-db1 \
 	--without-db2 \
 	--without-db3 \
 	--without-qdbm \
 	--with-pdo-dblib \
 	--enable-opcache
EOF


# Add static compilation
sed -i "s/-export-dynamic/-all-static -export-dynamic/g" Makefile

make -j$(nproc) LDFLAGS=-static install

strip $DIR/$PACKAGE/bin/php $DIR/$PACKAGE/bin/php-cgi $DIR/$PACKAGE/bin/phpdbg $DIR/$PACKAGE/sbin/php-fpm
