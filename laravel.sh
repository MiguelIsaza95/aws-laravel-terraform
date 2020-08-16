#!/bin/bash

# Laravel Intallation process

# Install PHP and Nginx

sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

sudo yum -y install wget git vim nginx1w php71w-fpm php71w-pdo php71w-mbstring php71w-xml php71w-common php71w-cli mariadb-server php71w-mysql

#EFS file system
cd /home/centos
mkdir laravel
efs_dns="${efs_dns}"
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $efs_dns:/ laravel
sudo chown -R centos ./laravel/*

# Configure Nginx

sudo systemctl start nginx
sudo systemctl enable nginx

sudo systemctl start php-fpm
sudo systemctl enable php-fpm

# composer install
if [ -d /home/centos/laravel/quickstart ]; then
cd laravel
wget https://getcomposer.org/installer
sudo mv installer compose-setup.php
sudo php composer-setup.php
sudo mv composer.phar /usr/local/bin/composer
sudo ln -s /usr/local/bin/composer /usr/bin/composer
cd quickstart
sudo composer install
sudo ln -s /home/centos/laravel/quickstart /usr/share/nginx/html/quickstart
else
cd /usr/share/nginx/html
wget https://getcomposer.org/installer
sudo mv installer composer-setup.php
sudo php composer-setup.php
sudo mv composer.phar /usr/local/bin/composer
sudo ln -s /usr/local/bin/composer /usr/bin/composer
sudo composer create-project --prefer-dist laravel/laravel quickstart
sudo ln -s /usr/share/nginx/html/quickstart /home/centos/laravel/quickstart
fi

sudo wget https://raw.githubusercontent.com/MiguelIsaza95/aws-laravel-terraform/master/config_file/nginx.conf
sudo mv nginx.conf /etc/nginx/nginx.conf

sudo nginx -t

sudo systemctl restart nginx

# SeLinux ownership fix error
sudo sestatus
sudo setenforce 0
sudo chmod -R 775 /usr/share/nginx/html/quickstart/*
sudo chown -R apache.apache /usr/share/nginx/html/quickstart/
sudo chmod -R 777 /usr/share/nginx/html/quickstart/storage/*
sudo chown -R apache.apache /usr/share/nginx/html/quickstart/bootstrap/cache

sudo semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nginx/html/quickstart/bootstrap/cache(/.*)?'
sudo semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nginx/html/quickstart/storage(/.*)?'

sudo restorecon -Rv '/usr/share/nginx/html/quickstart'

# Configure Laravel Installation
sudo wget https://raw.githubusercontent.com/MiguelIsaza95/aws-laravel-terraform/master/config_file/.env
sudo mv .env /usr/share/nginx/html/quickstart/.env
cd quickstart/
sudo php artisan key:generate

# Database migration
#php artisan make:auth
#php artisan make:migration create_users_table
#php artisan make:migration create_users_table --create=users
#php artisan make:migration add_votes_to_users_table --table=users
#php artisan migrate --force

# Restart services
sudo systemctl restart nginx
sudo systemctl restart php-fpm