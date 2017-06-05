#!/bin/sh

###nginx install shell
###wugk 2012-07-14
###PATH DEFINE

SOFT_PATH=/data/soft/
NGINX_FILE=nginx-1.2.0.tar.gz
DOWN_PATH=http://nginx.org/download/

if[ $UID -ne 0 ];then
echo This script must use administrator or root user ,please exit!
sleep 2
exit 0
fi

if[ ! -d $SOFT_PATH ];then
mkdir -p $SOFT_PATH
fi

download ()
{
cd $SOFT_PATH ;wget $DOWN_PATH/$NGINX_FILE
}

install ()
{
yum install pcre-devel -y
cd $SOFT_PATH ;tar xzf $NGINX_FILE ;cd nginx-1.2.0/ &&./configure –prefix=/usr/local/nginx/ –with-http_stub_status_module –with-http_ssl_module
[ $? -eq 0 ]&&make &&make install
}

start ()
{
lsof -i :80[ $? -ne 0 ]&&/usr/local/nginx/sbin/nginx
}

stop ()
{
ps -ef |grep nginx |grep -v grep |awk ‘{print $2}’|xargs kill -9
}

exit ()
{
echo $? ;exit
}

###case menu #####

case $1 in
download )
download
;;

install )
install
;;

start )
start
;;
stop )
stop
;;

* )

echo “USAGE:$0 {download or install or start or stop}”
exit
esac
#自动安装Nginx脚本，采用case方式，选择方式