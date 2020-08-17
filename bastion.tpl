#!/bin/bash

sudo yum -y update
sudo yum -y install mysql

ser="${user}"
passwd="${passwd}"
host="${host}"

mysql -u$user -p$passwd -h $host -e "create database laravelaws;" 