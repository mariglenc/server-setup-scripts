#!/bin/bash

set -e

echo "--- Running 6.grant-remote-to-applications.sh ---"

MYSQL_CONF_FILE="/etc/mysql/mysql.conf.d/mysqld.cnf"

echo "Configuring MySQL to listen on all interfaces (bind-address = 0.0.0.0)"

if grep -qE "^\s*bind-address\s*=" "$MYSQL_CONF_FILE"; then
  sed -i 's/^\s*bind-address\s*=.*/bind-address = 0.0.0.0/' "$MYSQL_CONF_FILE"
else
  sed -i '/\[mysqld\]/a bind-address = 0.0.0.0' "$MYSQL_CONF_FILE"
fi

echo "Restarting MySQL service to apply bind-address change..."
systemctl restart mysql

MYSQL_ROOT_PASSWORD="MyslqEatech2025!!" # <<< CHANGE THIS!
APP_DB_USER="testdb" # <<< CHANGE THIS!
APP_DB_PASSWORD="testDb2025!!" # <<< CHANGE THIS!
APP_DB_NAME="testdb" # <<< CHANGE THIS to your actual DB name

echo "Securing MySQL root user and creating application database user."

# Create a temporary file for the root password for secure interaction
echo "[client]" > ~/.my.cnf
echo "user=root" >> ~/.my.cnf
echo "password=$MYSQL_ROOT_PASSWORD" >> ~/.my.cnf # Add new password if setting it later

chmod 600 ~/.my.cnf # Secure permissions for the temporary file

echo "Setting/Updating MySQL root password..."
mysql -u root --connect-expired-password -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';"

echo "Creating application database user '$APP_DB_USER' and granting privileges..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "
CREATE USER '$APP_DB_USER'@'%' IDENTIFIED BY '$APP_DB_PASSWORD';
GRANT ALL PRIVILEGES ON $APP_DB_NAME.* TO '$APP_DB_USER'@'%';
FLUSH PRIVILEGES;
"

echo "Removing temporary MySQL password file..."
rm ~/.my.cnf

echo "MySQL configuration for remote access and new user complete."
echo "Remember to configure your firewall (e.g., ufw) to allow port 3306 for MySQL if needed."

echo "Note: 'ALLOWED_HOSTS = ['*']' is likely an application-specific setting (e.g., Django)."
echo "This needs to be placed in your application's configuration file."

echo "--- Finished 6.grant-remote-to-applications.sh ---"