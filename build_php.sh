#!/bin/bash
mkdir -p /root/source;

TEST_MACHINE='root@xxxx.xxxx'
BUILD_PATH='/usr/local/php'
SOURCE_PATH='/root/kit'
MY_SOURCE_PATH='/root/source'

function _color()
{
    case "$1" in
        red)    nn="31";;
        green)  nn="32";;
        yellow) nn="33";;
        blue)   nn="34";;
        purple) nn="35";;
        cyan)   nn="36";;
    esac
    ff=""
    case "$2" in
        bold)   ff=";1";;
        bright) ff=";2";;
        uscore) ff=";4";;
        blink)  ff=";5";;
        invert) ff=";7";;
    esac
    color_begin=`echo -e -n "\033[${nn}${ff}m"`
    color_end=`echo -e -n "\033[0m"`
    while read line; do
        echo "${color_begin}${line}${color_end}"
    done
}

# 判断安装目录是否存在
if [ -d $BUILD_PATH ]; then
    BUILD_PATH='/usr/local/php5'
fi

if [ -d $BUILD_PATH ]; then
    echo '[-] 安装目录已经存在, 请修改安装目录' | _color red
    exit
fi
mkdir -p $BUILD_PATH

# 从测试机上面拉取源代码
scp $TEST_MACHINE:$SOURCE_PATH/mongo-php-driver-legacy-master.zip $MY_SOURCE_PATH
scp $TEST_MACHINE:$SOURCE_PATH/redis-2.2.7.tgz $MY_SOURCE_PATH
scp $TEST_MACHINE:$SOURCE_PATH/php-5.6.19.tar.gz $MY_SOURCE_PATH

cd $MY_SOURCE_PATH
tar -zvxf redis-2.2.7.tgz
tar -zvxf php-5.6.19.tar.gz
unzip mongo-php-driver-legacy-master.zip

cd $MY_SOURCE_PATH/php-5.6.19
./configure --enable-fpm --with-mysql --prefix=$BUILD_PATH
make
make install

cp php.ini-development $BUILD_PATH/lib/php.ini
cp $BUILD_PATH/etc/php-fpm.conf.default $BUILD_PATH/etc/php-fpm.conf

# 为php-fpm 添加用户/用户组
groupadd www-data >/dev/null 2>&1
useradd -g www-data www-data >/dev/null 2>&1

# 修改配置文件
sed -i 's/^user = nobody$/user = www-data/' $BUILD_PATH/etc/php-fpm.conf
sed -i 's/^group = nobody$/group = www-data/' $BUILD_PATH/etc/php-fpm.conf
# 配置php-fpm pid & port
sed -i 's/^;pid = run\/php-fpm.pid$/pid = run\/php-fpm.pid/' $BUILD_PATH/etc/php-fpm.conf
# php-fpm 已经使用了, 修改端口
if [ -n `netstat -apn | grep php-fpm` ]; then
    sed -i 's/^listen = 127.0.0.1:9000$/listen = 127.0.0.1:9001/' $BUILD_PATH/etc/php-fpm.conf
fi

# php-fpm 自启动脚本
cp php5-fpm.sh /ext/init.d/php5-fpm

mkdir -p $BUILD_PATH/ext

# 安装扩展 REDIS / MONGO
echo "[+] 开始安装redis" | _color green
cd $MY_SOURCE_PATH/redis-2.2.7
$BUILD_PATH/bin/phpize
./configure --with-php-config=$BUILD_PATH/bin/php-config
make
THE_EXTENSIONS=`make install | grep -P "$BUILD_PATH/lib/php/extensions/no-debug-non-zts-\d{8}" -o`
cp $THE_EXTENSIONS/redis.so $BUILD_PATH/ext/redis.so

echo "[+] 开始安装mongo" | _color green
cd $MY_SOURCE_PATH/mongo-php-driver-legacy-master
$BUILD_PATH/bin/phpize
./configure --with-php-config=$BUILD_PATH/bin/php-config
make
THE_EXTENSIONS=`make install | grep -P "$BUILD_PATH/lib/php/extensions/no-debug-non-zts-\d{8}" -o`
cp $THE_EXTENSIONS/mongo.so $BUILD_PATH/ext/mongo.so

# 修改php.ini 添加扩展 (!-.- 直接复制测试机上面的php.ini)
scp $TEST_MACHINE:/usr/local/php/lib/php.ini $BUILD_PATH/lib/php.ini

# 重启php-fpm
/etc/init.d/php5-fpm stop >/dev/null 2>&1
/etc/init.d/php5-fpm start

echo '[+] 完成安装, php-fpm服务已启动' | _color green

cd -
