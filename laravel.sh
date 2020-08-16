#!/bin/bash
su -u centos bash <<<EOF
    # Laravel Intallation process

    #EFS file system
    cd /home/centos
    if [ -d ./laravel ]; then
    echo "Already exist"
    sudo chown -R centos ./laravel/*
    else
    mkdir laravel
    sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-3dd914bf.efs.us-east-1.amazonaws.com:/ laravel
    sudo chown -R centos ./laravel/*
    fi

    # Install PHP and Nginx

    sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
    sudo rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

    sudo yum -y install wget git vim nginx1w php71w-fpm php71w-pdo php71w-mbstring php71w-xml php71w-common php71w-cli mariadb-server php71w-mysql
    
    # Install composer
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    sudo chmod +x /usr/local/bin/composer
    sudo ln -s /usr/local/bin/composer /usr/bin/composer

    # Configure Mysql
    sudo systemctl start mariadb
    sudo systemctl enable mariadb

    # Configure Nginx

    sudo systemctl start nginx
    sudo systemctl enable nginx

    sudo systemctl start php-fpm
    sudo systemctl enable php-fpm

    # composer install
    cd laravel
    if [ -d ./quickstart ]; then
    echo "Already exist"
    cd quickstart
    sudo composer install

    # SeLinux ownership fix error
    sudo sestatus
    sudo setenforce 0
    sudo chmod -R 775 /home/centos/laravel/quickstart/
    sudo chown -R apache.apache /home/centos/laravel/quickstart/
    sudo chmod -R 777 /home/centos/laravel/quickstart/storage/
    sudo chown -R apache.apache /home/centos/laravel/quickstart/bootstrap/cache

    sudo semanage fcontext -a -t httpd_sys_rw_content_t '/home/centos/laravel/quickstart/bootstrap/cache(/.*)?'
    sudo semanage fcontext -a -t httpd_sys_rw_content_t '/home/centos/laravel/quickstart/storage(/.*)?'

    sudo restorecon -Rv '/home/centos/laravel/quickstart'

    sudo php artisan key:generate
    sudo php artisan make:auth
    else
 #   git clone https://github.com/laravel/quickstart-basic quickstart
 #   cd quickstart
 #   sudo composer install
    sudo composer create-project --prefer-dist laravel/laravel quickstart

    # SeLinux ownership fix error
    sudo sestatus
    sudo setenforce 0
    sudo chmod -R 775 /home/centos/laravel/quickstart/
    sudo chown -R apache.apache /home/centos/laravel/quickstart/
    sudo chmod -R 777 /home/centos/laravel/quickstart/storage/
    sudo chown -R apache.apache /home/centos/laravel/quickstart/bootstrap/cache

    sudo semanage fcontext -a -t httpd_sys_rw_content_t '/home/centos/laravel/quickstart/bootstrap/cache(/.*)?'
    sudo semanage fcontext -a -t httpd_sys_rw_content_t '/home/centos/laravel/quickstart/storage(/.*)?'

    sudo restorecon -Rv '/home/centos/laravel/quickstart'

    sudo php artisan key:generate
    sudo php artisan make:auth
    fi

    cd ..
    wget https://raw.githubusercontent.com/MiguelIsaza95/aws-laravel-terraform/master/config_file/nginx.conf
    sudo mv nginx.conf /etc/nginx/nginx.conf

    sudo systemctl restart nginx
    # Configure Laravel Installation
    #wget https://raw.githubusercontent.com/MiguelIsaza95/aws-laravel-terraform/master/config_file/.env
    #mv .env /usr/share/nginx/html/quickstart/.env

    # Database migration
    mysql -uroot -e "create database laravel;"
    sudo php artisan session:table
    sudo php artisan migrate

    # Restart services
    sudo systemctl restart nginx
    sudo systemctl restart php-fpm
EOF