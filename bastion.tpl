#!/bin/bash

sudo yum -y update
sudo yum -y install mysql

user="${user}"
passwd="${passwd}"
host="${host}"

mysql -u$user -p$passwd -h $host -e "use laravelaws; create table laravelaws;"