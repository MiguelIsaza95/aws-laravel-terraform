#!/bin/bash

# Install Laravel
suo yum -y update
sudo yum -y install php-cli php-zip wget unzip mysql-server
sudo service mysqld start
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php --install-dir=/usr/local/bin --filename=composer


composer

composer create-project laravel/laravel quickstart --prefer-dist
git clone https://github.com/laravel/quickstart-basic quickstart
cd quickstart
composer install
php artisan migrate
php artisan serve