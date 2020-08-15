#!/bin/bash

# Laravel Intallation process

# Install PHP and Nginx

sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

sudo yum -y install wget git nginx1w php71w-fpm php71w-pdo php71w-mbstring php71w-xml php71w-common php71w-cli

# Configure Nginx

sudo systemctl start nginx
sudo systemctl enable nginx

sudo systemctl start php-fpm
sudo systemctl enable php-fpm

# Swap fixing for composer install
sudo /bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
sudo /sbin/mkswap /var/swap.1
sudo /sbin/swapon /var/swap.1

# Install composer
sudo curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer
sudo ln -s /usr/local/bin/composer /usr/bin/composer

# composer install
cd /usr/share/nginx/html
sudo composer create-project --prefer-dist laravel/laravel quickstart
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
sudo chown -R apache.apache /usr/share/nginx/html/testapp/bootstrap/cache

sudo semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nginx/html/quickstart/bootstrap/cache(/.*)?'
sudo semanage fcontext -a -t httpd_sys_rw_content_t '/usr/share/nginx/html/quickstart/storage(/.*)?'

sudo restorecon -Rv '/usr/share/nginx/html/quickstart'

# Configure Laravel Installation
sudo wget https://raw.githubusercontent.com/MiguelIsaza95/aws-laravel-terraform/master/config_file/.env
sudo mv .env /usr/share/nginx/html/quickstart/.env
cd quickstart/
sudo php artisan key:generate

# Database migration
#sudo php artisan migrate

# Restart services
sudo systemctl restart nginx
sudo systemctl restart php-fpm

