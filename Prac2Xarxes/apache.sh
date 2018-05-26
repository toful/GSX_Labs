#!/bin/bash

#Copia el contingut html als directoris creats per cada site
mkdir /var/www/html/taller
mkdir /var/www/html/tenda
cp html_files/index.html /var/www/html/index.html
cp html_files/taller.html /var/www/html/taller/index.html
cp html_files/tenda.html /var/www/html/tenda/index.html

#Copia els fitxers de configuració dels virtual hosts
cp html_files/taller.conf /etc/apache2/sites-available/taller.conf
cp html_files/tenda.conf /etc/apache2/sites-available/tenda.conf

#Crea la carpeta d’aministracio i afegeix el fitxer .htacces
mkdir /var/www/html/taller/admin
cp html_files/taller.htaccess /var/www/html/taller/admin/.htaccess

#Habilita els virtual hosts 
cd /etc/apache2/sites-available
a2ensite taller.conf
a2ensite tenda.conf

#Reinicia el servei apache
service apache2 restart
