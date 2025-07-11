nano /etc/mysql/mysql.conf.d/mysqld.cnf       
  add line: bind-address = 0.0.0.0
  
ALLOWED_HOSTS = ['*']

mysql -u root -p'pwd'
UPDATE mysql.user  SET Host='%'  WHERE User='root' AND Host='localhost';