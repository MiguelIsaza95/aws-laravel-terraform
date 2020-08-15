#!/bin/bash

# Laravel Intallation process

# Install PHP and Nginx

sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -Uvh https://mirror.webtatic.com/yum/el7/webtatic-release.rpm

sudo yum -y install wget git nginx1w php71w-fpm php71w-pdo php71w-mbstring php71w-xml php71w-common php71w-cli

# Configure Nginx

wget 
sudo systemctl start nginx
sudo systemctl enable nginx