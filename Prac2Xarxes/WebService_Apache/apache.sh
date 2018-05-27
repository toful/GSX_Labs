#!/bin/bash

mkdir /var/www/html/taller
mkdir /var/www/html/tenda
cp html_files/index.html /var/www/html/index.html
cp html_files/taller.html /var/www/html/taller/index.html
cp html_files/tenda.html /var/www/html/tenda/index.html

cp html_files/taller.conf /etc/apache2/sites-available/taller.conf
cp html_files/tenda.conf /etc/apache2/sites-available/tenda.conf

cd /etc/apache2/sites-available
a2ensite taller.conf
a2ensite tenda.conf

service apache2 restart

