#!/bin/bash

#Crea la carpeta d’aministracio i afegeix el fitxer .htacces
mkdir /var/www/html/taller/admin
cp -p ./admin/taller_htaccess /var/www/html/taller/admin/.htaccess

#Reinicia el servei apache
service apache2 restart
