#!/bin/bash

# Install Laravel
sudo yum -y update
sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-12.noarch.rpm
sudo rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

sudo yum -y --enablerepo=remi,epel install httpd
sudo yum -y --enablerepo=remi,epel install mysql
sudo yum -y --enablerepo=remi,epel install php php-zip php-mysql php-mcrypt php-xml php-mbstring git
curl -sS https://getcomposer.org/installer | php
sudo chmod 777 /usr/local/bin
php composer-setup.php --install-dir=/usr/local/bin --filename=composer


composer

composer create-project laravel/laravel quickstart --prefer-dist
git clone https://github.com/laravel/quickstart-basic quickstart
cd quickstart
composer install
php artisan migrate
php artisan serve