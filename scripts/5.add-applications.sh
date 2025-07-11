apt update

# Utils
apt-get install htop -y

# Nginx
apt-get install nginx certbot python3-certbot-nginx git -y
systemctl status nginx
systemctl status certbot

# Php
apt install -y php7.4 php7.4-cli php7.4-common php7.4-fpm php7.4-mysql php7.4-curl php7.4-mbstring php7.4-xml php7.4-zip php7.4-bcmath php7.4-soap
php -v

# MySQL
wget https://dev.mysql.com/get/mysql-apt-config_0.8.29-1_all.deb
dpkg -i mysql-apt-config_0.8.29-1_all.deb
apt update
apt install mysql-server -y
systemctl status mysql
#mysql -u root -p'pwd'
