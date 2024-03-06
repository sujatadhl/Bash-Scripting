
#!/bin/bash 
sudo apt-get udpate

sudo apt install apache2
sudo systemctl enable apache2


sudo apt install mysql-server
sudo systemctl enable mysql

sudo apt install php libapache2-mod-php php-mysql
sudo apt install php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip

cd /var/www/html/ 
sudo wget -c http://wordpress.org/latest.tar.gz
sudo tar -zxvf latest.tar.gz 

user="wpuser" 
pass="wordpress" 
dbname="wpdb"

mysql -e "CREATE DATABASE $dbname;"
mysql -e "CREATE USER '$user'@'localhost' IDENTIFIED BY '$pass';"
mysql -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"
cd wordpress

chown -R www-data:www-data /var/www/html/wordpress/
chmod -R 755 /var/www/html/wordpress/


cp wp-config-sample.php wp-config.php
chown -R www-data:www-data wp-config.php

sed -i "s/database_name_here/$dbname/" wp-config.php
sed -i "s/username_here/$user/" wp-config.php
sed -i "s/password_here/$pass/" wp-config.php 

touch /etc/apache2/sites-available/wordpress.conf
cat > /etc/apache2/sites-available/wordpress.conf <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www/html/wordpress
    <Directory /var/www/html/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /var/www/html/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
EOF

sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo a2dissite 000-default
sudo service apache2 reload




