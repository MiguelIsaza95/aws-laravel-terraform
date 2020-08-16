#!/bin/bash

# Laravel Intallation process

#EFS file system
mkdir /home/centos/laravel
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-3dd914bf.efs.us-east-1.amazonaws.com:/ laravel

# Install composer
su centos -c "curl -sS https://getcomposer.org/installer | php"
su centos -c "mv composer.phar /usr/local/bin/composer"
su centos -c "chmod +x /usr/local/bin/composer"
su centos -c "ln -s /usr/local/bin/composer /usr/bin/composer"

# Install PHP and Nginx

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

yum -y install wget git vim nginx1w php71w-fpm php71w-pdo php71w-mbstring php71w-xml php71w-common php71w-cli

# Configure Nginx

systemctl start nginx
systemctl enable nginx

systemctl start php-fpm
systemctl enable php-fpm

# composer install
cd /home/centos/laravel
composer create-project --prefer-dist laravel/laravel quickstart
#git clone https://github.com/laravel/quickstart-basic quickstart
#composer install
su centos -c 'wget https://raw.githubusercontent.com/MiguelIsaza95/aws-laravel-terraform/master/config_file/nginx.conf'
su centos -c 'sudo mv nginx.conf /etc/nginx/nginx.conf'

systemctl restart nginx

# SeLinux ownership fix error
sestatus
setenforce 0
chmod -R 775 /home/centos/laravel/quickstart/*
chown -R apache.apache /home/centos/laravel/quickstart/
chmod -R 777 /home/centos/laravel/quickstart/storage/*
chown -R apache.apache /home/centos/laravel/quickstart/bootstrap/cache

semanage fcontext -a -t httpd_sys_rw_content_t '/home/centos/laravel/quickstart/bootstrap/cache(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/home/centos/laravel/quickstart/storage(/.*)?'

restorecon -Rv '/home/centos/laravel/quickstart'

# Configure Laravel Installation
#wget https://raw.githubusercontent.com/MiguelIsaza95/aws-laravel-terraform/master/config_file/.env
#mv .env /usr/share/nginx/html/quickstart/.env
cd quickstart/
#composer install
php artisan key:generate

# Database migration
yum -y install mariadb-server php71w-mysql
systemctl start mariadb
systemctl enable mariadb
su centos -c 'mysql -uroot -e "create laravel;"'
php artisan make:auth
php artisan session:table
php artisan migrate

# Restart services
systemctl restart nginx
systemctl restart php-fpm