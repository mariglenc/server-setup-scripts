#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo "--- Running 5.add-applications.sh ---"

echo "Updating apt cache..."
apt update -y

echo "Installing utilities, Nginx, Certbot, Git..."
apt install -y htop nginx certbot python3-certbot-nginx git

echo "Checking Nginx and Certbot service status (should be installed)"
systemctl is-active --quiet nginx && echo "Nginx is active." || echo "Nginx is not active."
systemctl is-enabled --quiet nginx && echo "Nginx is enabled." || echo "Nginx is not enabled."

systemctl is-active --quiet certbot && echo "Certbot is active." || echo "Certbot is not active."
systemctl is-enabled --quiet certbot && echo "Certbot is enabled." || echo "Certbot is not enabled."


echo "Installing PHP 7.4 and modules..."
apt install -y php7.4 php7.4-cli php7.4-common php7.4-fpm php7.4-mysql php7.4-curl php7.4-mbstring php7.4-xml php7.4-zip php7.4-bcmath php7.4-soap
php -v

# --- MySQL Installation (Fully Automated) ---
echo "Installing gnupg (pre-dependency for MySQL APT config)..."
apt install -y gnupg

echo "--- Configuring and Installing MySQL Server ---"
# Define the MySQL APT config package path
MYSQL_APT_CONFIG_DEB="/tmp/mysql-apt-config_0.8.29-1_all.deb"

echo "Downloading MySQL APT config..."
wget https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb -O "$MYSQL_APT_CONFIG_DEB"

echo "Pre-seeding MySQL APT config selections..."
echo "mysql-apt-config mysql-apt-config/select-product select MySQL Server & Cluster" | debconf-set-selections
echo "mysql-apt-config mysql-apt-config/select-server select mysql-8.0" | debconf-set-selections

echo "Installing MySQL APT config package..."

DEBIAN_FRONTEND=noninteractive dpkg -i "$MYSQL_APT_CONFIG_DEB"
rm "$MYSQL_APT_CONFIG_DEB"

echo "Updating apt cache after adding MySQL repository..."
apt update -y

echo "Installing MySQL Server non-interactively..."
DEBIAN_FRONTEND=noninteractive apt install -y mysql-server

echo "Checking MySQL service status..."
systemctl is-active --quiet mysql && echo "MySQL is active." || echo "MySQL is not active."
systemctl is-enabled --quiet mysql && echo "MySQL is enabled." || echo "MySQL is not enabled."

echo "--- MySQL Server installation complete ---"