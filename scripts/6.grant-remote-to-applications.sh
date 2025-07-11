#!/bin/bash

set -e

MYSQL_CONF_FILE="/etc/mysql/mysql.conf.d/mysqld.cnf"
MYSQL_ROOT_PASSWORD="MyslqEatech2025!!"

sed -i '/\[mysqld\]/a bind-address = 0.0.0.0' "$MYSQL_CONF_FILE"

systemctl restart mysql

echo "[client]" > ~/.my.cnf
echo "user=root" >> ~/.my.cnf
echo "password=$MYSQL_ROOT_PASSWORD" >> ~/.my.cnf
chmod 600 ~/.my.cnf 
mysql -u root --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;"
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"

rm ~/.my.cnf