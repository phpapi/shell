NGINX_CONFIG='/usr/local/nginx/conf/vhosts/sites-available'
NGINX_SITES_ENABLED='/usr/local/nginx/conf/vhosts'
WEB_DIR='/home/vagrant/sync/example'
SED=`which sed`
CURRENT_DIR=`dirname $0`
status='1'
date=`sudo date`

if [ -z $1 ]; then
    status="0"
	output="No domain name given"
	echo -e "{\"status\":\""$status"\", \"msg\":\""$output"\",\"data\":\"""\", \"uptime\":\""$date"\"}"
    exit;
fi

prefix=$(date +%s%N)
DOMAIN=$prefix.$1

# check the domain is roughly valid!
PATTERN="^([[:alnum:]]([[:alnum:]\-]{0,61}[[:alnum:]])?\.)+[[:alpha:]]{2,6}$"
if [[ "$DOMAIN" =~ $PATTERN ]]; then
	DOMAIN=`echo $DOMAIN | tr '[A-Z]' '[a-z]'`
	output="Creating hosting for:"$DOMAIN
else
    status="0"
	output="invalid domain name"
    echo -e "{\"status\":\""$status"\", \"msg\":\""$output"\",\"data\":\"""\", \"uptime\":\""$date"\"}"
    exit;
fi

### check if domain already exists
if [ -e $NGINX_CONFIG$DOMAIN ]; then
    status="0"
    output="This domain already exists.\nPlease Try Another one"
    echo -e "{\"status\":\""$status"\", \"msg\":\""$output"\",\"data\":\"""\", \"uptime\":\""$date"\"}"
    exit;
fi

#Replace dots with underscores
SITE_DIR=`echo $DOMAIN | $SED 's/\./_/g'`

# Now we need to copy the virtual host template
CONFIG=$NGINX_CONFIG/$DOMAIN.conf
sudo cp $CURRENT_DIR/virtual_host.template $CONFIG
sudo $SED -i "s/DOMAIN/$DOMAIN/g" $CONFIG
sudo $SED -i "s!ROOT!$WEB_DIR/$SITE_DIR!g" $CONFIG

# set up web root
sudo mkdir $WEB_DIR/$SITE_DIR
sudo chown vagrant:vagrant -R $WEB_DIR/$SITE_DIR
sudo chmod 600 $CONFIG

# create symlink to enable site
sudo ln -s $CONFIG $NGINX_SITES_ENABLED/$DOMAIN.conf

# reload Nginx to pull in new config
sudo /usr/local/nginx/sbin/nginx -s reload

# put the template index.html file into the new domains web dir
sudo cp $CURRENT_DIR/index.html.template $WEB_DIR/$SITE_DIR/index.html
sudo $SED -i "s/SITE/$DOMAIN/g" $WEB_DIR/$SITE_DIR/index.html
sudo chown vagrant:vagrant $WEB_DIR/$SITE_DIR/index.html

### create mysql database
#echo -e $"create mysql database core--$DOMAIN start \n"
#sh /home/vagrant/sync/shell/create_nginx_vhost/mysql.sh "core"$prefix


MYSQL_BIN="/usr/local/mysql/bin/mysql"
MYSQL_ROOT="stars"
MYSQL_PASS="123456"
MYSQL_HOST="192.168.200.29"
DB="core"$prefix
#echo "DATABASES IS :"$DB":"
if [ $MYSQL_PASS ]
then
  #echo "logging into as $MYSQL_ROOT"
  sudo $MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -e "create database $DB"
  #$MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -e "SHOW DATABASES"
  sudo $MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" $DB < /home/vagrant/sync/shell/create_nginx_vhost/core.sql
else
  $MYSQL_BIN -u "$MYSQL_ROOT" -e "SHOW DATABASES"
fi

### Add db config to WEB_DIR
sudo cp $CURRENT_DIR/db.php $WEB_DIR/$SITE_DIR/$DOMAIN.php
sudo $SED -i "s/CORE/$DB/g" $WEB_DIR/$SITE_DIR/$DOMAIN.php
sudo chown vagrant:vagrant $WEB_DIR/$SITE_DIR/$DOMAIN.php

output='Site Created for '$DOMAIN
echo -e "{\"status\":\""$status"\", \"msg\":\""$output"\",\"data\":\""$DOMAIN"\", \"uptime\":\""$date"\"}"
exit;