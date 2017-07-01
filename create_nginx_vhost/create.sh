NGINX_CONFIG='/usr/local/nginx/conf/vhosts/sites-available'
NGINX_SITES_ENABLED='/usr/local/nginx/conf/vhosts'
WEB_DIR='/home/vagrant/sync/example'
SED=`which sed`
CURRENT_DIR=`dirname $0`
status='1'
date=`sudo date`

# check the domain is null
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

### create nginx virtual host
SITE=($DOMAIN m.$DOMAIN agent.$DOMAIN imc.$DOMAIN)
for a in "${SITE[@]}"; do
    SITE_DIR=`echo $a | $SED 's/\./_/g'`
    CONFIGM=$NGINX_CONFIG/$a.conf
    sudo cp $CURRENT_DIR/virtual_host.template $CONFIGM
    sudo $SED -i "s/DOMAIN/$a/g" $CONFIGM
    sudo $SED -i "s!ROOT!$WEB_DIR/$SITE_DIR!g" $CONFIGM

    sudo mkdir $WEB_DIR/$SITE_DIR
    sudo chown vagrant:vagrant -R $WEB_DIR/$SITE_DIR
    sudo chmod 600 $CONFIGM

    sudo ln -s $CONFIGM $NGINX_SITES_ENABLED/$a.conf

    # reload Nginx to pull in new config
    sudo /usr/local/nginx/sbin/nginx -s reload

    # put the template index.html file into the new domains web dir
    sudo cp $CURRENT_DIR/index.html.template $WEB_DIR/$SITE_DIR/index.html
    sudo $SED -i "s/SITE/$a/g" $WEB_DIR/$SITE_DIR/index.html
    sudo chown vagrant:vagrant $WEB_DIR/$SITE_DIR/index.html
done

### create mysql database data initialization
#echo -e $"create mysql database core--$DOMAIN start \n"
#sh /home/vagrant/sync/shell/create_nginx_vhost/mysql.sh "core"$prefix

MYSQL_BIN="/usr/local/mysql/bin/mysql"
MYSQL_ROOT="stars"
MYSQL_PASS="123456"
MYSQL_HOST="192.168.200.29"
DB="core"$prefix
DB_NAME='master'
TIME=`date -d "$currentTime" +%s`
if [ $MYSQL_PASS ]
then
  #echo "logging into as $MYSQL_ROOT"
  sudo $MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -e "create database $DB"
  #$MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -e "SHOW DATABASES"
  sudo $MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" $DB < /home/vagrant/sync/shell/create_nginx_vhost/core.sql
  sudo $MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -e "use master"
  SQL="INSERT INTO address_config (pc_address,h5_address,admin_address,created,updated)VALUES('$DOMAIN','m.$DOMAIN','imc.$DOMAIN',$TIME,$TIME)"
  sudo $MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" $DB_NAME << EOF
    $SQL
EOF
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