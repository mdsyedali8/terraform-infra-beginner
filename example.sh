#!bin/bash

apt-get update
apt-get install apache2 -y
git clone https://github.com/amolshete/card-website.git
cp -rf card-website/* /var/www/html