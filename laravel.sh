#!/bin/bash

# Laravel Intallation process

#EFS file system
cd /home/centos
if [-d ./laravel]
then
echo "Already exist"
else
su centos -c 'mkdir laravel'
su centos -c 'sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-3dd914bf.efs.us-east-1.amazonaws.com:/ laravel'
fi

# Install PHP and Nginx

rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

yum -y install wget git vim nginx1w php71w-fpm php71w-pdo php71w-mbstring php71w-xml php71w-common php71w-cli mariadb-server php71w-mysql

# Install composer
su centos -c 'php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"'
su centos -c "sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer"
su centos -c "sudo chmod +x /usr/local/bin/composer"
su centos -c "sudo ln -s /usr/local/bin/composer /usr/bin/composer"

# Configure Mysql
systemctl start mariadb
systemctl enable mariadb

# Configure Nginx

systemctl start nginx
systemctl enable nginx

systemctl start php-fpm
systemctl enable php-fpm

# composer install
cd laravel
#composer create-project --prefer-dist laravel/laravel quickstart
su centos -c 'git clone https://github.com/laravel/quickstart-basic quickstart'
cd ..
su centos -c 'sudo wget https://raw.githubusercontent.com/MiguelIsaza95/aws-laravel-terraform/master/config_file/nginx.conf'
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
cd /laravel/quickstart/
su centos -c 'sudo composer install'
su centos -c 'sudo php artisan key:generate'

# Database migration
su centos -c 'mysql -uroot -e "create database laravel;"'
su centos -c 'sudo php artisan make:auth'
su centos -c 'sudo php artisan session:table'
su centos -c 'sudo php artisan migrate'

# Restart services
systemctl restart nginx
systemctl restart php-fpm