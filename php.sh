#!/usr/bin/env bash

mkdir -p ~/work/sorcecode/
cd ~/work/sorcecode/

wget http://cn2.php.net/distributions/php-5.6.19.tar.gz
tar -zvxf php-5.6.19.tar.gz

cd php-5.6.19

# 安装xml
# debain-os
apt-get install libxml2-dev
# center-os
yum install libxml2-devel

./configure --enable-fpm --with-mysql --prefix=/usr/local/php
make && make install

cp php.ini-development /usr/local/php/lib/php.ini
cp /usr/local/php/etc/php-fpm.conf.default /usr/local/php/etc/php-fpm.conf
cp sapi/fpm/php-fpm /bin
cp /usr/local/php/bin/* /bin/
cd /usr/local/php/etc
cat php-fpm.conf | sed 's/^user = no-body$/user = www-data/' > php-fpm.conf
cat php-fpm.conf | sed 's/^group = no-body$/group = www-data/' > php-fpm.conf

#/usr/local/php/bin/phpize
#./configure --with-php-config=/usr/local/php/bin/php-config

