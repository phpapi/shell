MYSQL_ROOT="stars"
MYSQL_PASS="123456"
MYSQL_HOST="192.168.200.29"
DB=$1

if [ $MYSQL_PASS ]
then
  sudo mysql -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -e "create database $DB"
  sudo mysql -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" -e "SHOW DATABASES"
  sudo mysql -u "$MYSQL_ROOT" -p"$MYSQL_PASS" -h"$MYSQL_HOST" $DB < core.sql
else
  sudo mysql -u "$MYSQL_ROOT" -e "SHOW DATABASES"
fi