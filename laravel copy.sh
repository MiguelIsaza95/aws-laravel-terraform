#!/bin/bash

# Laravel Intallation process

# Install PHP and Nginx

sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

sudo yum -y install wget git vim nginx1w php71w-fpm php71w-pdo php71w-mbstring php71w-xml php71w-common php71w-cli

#EFS file system
cd /home/centos
if [ -d ./laravel ]; then
echo "Already exist"
sudo chown -R centos ./laravel/*
sudo rm -rf ./laravel/*
else
mkdir laravel
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-3dd914bf.efs.us-east-1.amazonaws.com:/ laravel
sudo chown -R centos ./laravel/*
sudo rm -rf ./laravel/*
fi

cd
# Configure Nginx

sudo systemctl start nginx
sudo systemctl enable nginx

sudo systemctl start php-fpm
sudo systemctl enable php-fpm

# Install composer
sudo curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer
sudo ln -s /usr/local/bin/composer /usr/bin/composer

# composer install
cd /usr/share/nginx/html
sudo composer create-project --prefer-dist laravel/laravel quickstart
sudo ln -s /usr/share/nginx/html/quickstart /home/centos/laravel/quickstart
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
#sudo php artisan migrate

# Restart services
sudo systemctl restart nginx
sudo systemctl restart php-fpm