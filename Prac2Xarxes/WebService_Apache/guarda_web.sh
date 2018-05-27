#!/bin/bash

#Crea els directoris separant el contingut propi del web del de config Apache
mkdir websites
mkdir websites/html
mkdir websites/apache

#Copia el contingut html i les configuracions
cp -p /var/www/html ./websites/html
cp -p /etc/apache2/sites-available ./websites/apache

#Comprimeix els fitxers en format tgz
tar -cvzf websites.tgz ./websites
