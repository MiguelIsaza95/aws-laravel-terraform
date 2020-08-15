#!/bin/bash

# Laravel Intallation process

# Install PHP and Nginx

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

yum -y install wget git vim nginx1w php71w-fpm php71w-pdo php71w-mbstring php71w-xml php71w-common php71w-cli

# Configure Nginx

systemctl start nginx
systemctl enable nginx

systemctl start php-fpm
systemctl enable php-fpm

# Install composer
curl -sS https://getcomposer.org/installer | php
mv composer.phar /usr/local/bin/composer
chmod +x /usr/local/bin/composer
ln -s /usr/local/bin/composer /usr/bin/composer

# composer install
cd /usr/share/nginx/html
composer create-project --prefer-dist laravel/laravel quickstart
wget https://raw.githubusercontent.com/MiguelIsaza95/aws-laravel-terraform/master/config_file/nginx.conf
mv nginx.conf /etc/nginx/nginx.conf

nginx -t

systemctl restart nginx

# SeLinux ownership fix error
sestatus
setenforce 0
chmod -R 775 /usr/share/nginx/html/quickstart/*
chown -R apache.apache /usr/share/nginx/html/quickstart/
chmod -R 777 /usr/share/nginx/html/quickstart/storage/*
chown -R apache.apache /usr/share/nginx/html/quickstart/bootstrap/cache

semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nginx/html/quickstart/bootstrap/cache(/.*)?'
semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nginx/html/quickstart/storage(/.*)?'

restorecon -Rv '/usr/share/nginx/html/quickstart'

# Configure Laravel Installation
wget https://raw.githubusercontent.com/MiguelIsaza95/aws-laravel-terraform/master/config_file/.env
mv .env /usr/share/nginx/html/quickstart/.env
cd quickstart/
php artisan key:generate

# Database migration
yum -y install mariadb-server php71w-mysql
sudo systemctl start mariadb
sudo systemctl enable mariadb
php artisan make:auth
php artisan session:table
php artisan migrate

# Restart services
systemctl restart nginx
systemctl restart php-fpm