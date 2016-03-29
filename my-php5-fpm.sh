#!/bin/bash

BUILD_PATH=/usr/local/php
PID_PATH=$BUILD_PATH/var/run

do_start() {
    `$BUILD_PATH/sbin/php-fpm`
}

do_stop() {
    kill `cat $PID_PATH/php-fpm.pid`
}

case $1 in
    start)
        do_start
        echo -e "[\033[32m+\033[0m] \033[32mstart successfully\033[0m"
    ;;

    restart)
        do_stop
        do_start
        echo -e "[\033[32m+\033[0m] \033[32mrestart successfully\033[0m"
    ;;

    stop)
        do_stop
        echo -e "[\033[32m+\033[0m] \033[32mstop successfully\033[0m"
    ;;
esac