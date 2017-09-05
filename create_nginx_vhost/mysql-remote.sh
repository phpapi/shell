MYSQL_BIN="/usr/local/mysql/bin/mysql"
MYSQL_ROOT="admin"
MYSQL_PASS="admin1@3"
MYSQL_HOST="10.100.63.63"
DB=$1
DB2=$2
DB3=$3

if [ $MYSQL_PASS ]
then
  sudo $MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -e "create database $DB"
  #sudo $MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -e "SHOW DATABASES"
  sudo $MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" $DB < init.sql

  sudo $MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -e "create database $DB2"
  sudo $MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" $DB2 < games.sql

  sudo $MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -e "create database $DB3"
  sudo $MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" $DB3 < data.sql

  #sudo $MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -e "SHOW DATABASES"
  #sudo $MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -e "use master"
  #SQL="INSERT INTO address_config (pc_address,h5_address,admin_address,created,updated)VALUES('$DOMAIN','m.$DOMAIN','imc.$DOMAIN',$TIME,$TIME)"
  #sudo $MYSQL_BIN -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" $DB_NAME << EOF
  #  $SQL
#EOF

else
  sudo $MYSQL_BIN -u "$MYSQL_ROOT" -e "SHOW DATABASES"
fi