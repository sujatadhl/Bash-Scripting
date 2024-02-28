
#!/bin/bash

#update
sudo apt-get udpate

#install apache2 web server"
sudo apt install apache2 

#install database"
sudo apt install mysql-server 

#install php 
sudo apt install php libapache2-mod-php php-mysql
sudo apt install php-curl php-gd php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip

sudo systemctl restart apache2
sudo systemctl restart mysql

#enable service
systemctl enable apache2
systemctl enable mysql

cd /var/ww/html/

#install wordpress 
sudo wget -c http://wprdpress.org/latest.tar.gz
sudo tar -zxvf latest.tar.gz

#variable database
user="user"
pass="wordpress"
dbname="my_db"

#create db name
mysql -e "CREATE DATABASE $dbname;"

#create new user
mysql -e "CREATE USER '$user'@'localhost' IDENTIFIED BY '$pass';"

#Grant ALL privileges on $dbname to $user!"
mysql -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

#Change owner & chmod
chown -R www-data:www-data wordpress/
chmod -R 755 wordpress/

cd /wordpress/

#create wp config
cp wp-config-sample.php wp-config.php
chown -R www-data:www-data wp-config.php

#set database details with find and replace
sed -i "s/database_name_here/$dbname/g" wp-config.php
sed -i "s/username_here/$user/g" wp-config.php
Sed -i "s/password_here/$pass/g" wp-config.php


#Create VirtualHost apache2 for wordpress
touch /etc/apache2/sites-available/wordpress.conf
cat > /etc/apache2/sites-available/wordpress.conf <<EOF
<VirtualHost *:80>
    DocumentRoot /var/www/html/wordpress
    Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
EOF

#enable apache2
a2ensite wordpress.conf
a2enmod rewrite
a2dissite 000-default.conf
systemctl restart apache2

#Restart service Apache2
systemctl restart apache2
