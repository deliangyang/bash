
mkdir ~/work/sorcecode/
cd ~/work/sorcecode

wget http://nginx.org/download/nginx-1.9.12.tar.gz
tar -zvxf nginx-1.9.12.tar.gz

# 添加rewrite
wget ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.37.tar.gz
tar -zvxf pcre-8.37

# 添加ssl
wget ftp://ftp.openssl.org/source/openssl-1.0.0t.tar.gz
tar -zvxf openssl-1.0.0t.tar.gz

# 添加zlib
wget http://zlib.net/zlib-1.2.8.tar.gz
tar -zvxf zlib-1.2.8.tar.gz

cd nginx-1.9.12
./configure --prefix=/usr/local/nginx --with-zlib=~/work/sorcecode/zlib-1.2.8 --with-pcre=~/work/sorcecode/pcre-8.37
make && make install

groupadd www-data
useradd -g www-data www-data

cp /usr/local/nginx/sbin /bin/nginx
nginx -V
