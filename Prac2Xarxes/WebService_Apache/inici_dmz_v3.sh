#!/bin/bash

#Copia el contingut html al directori corresponent
cp -p websites/html /var/www/html

#Copia els fitxers de configuració dels virtual hosts al directori conf Apache
cp -p websites/apache /etc/apache2/sites-available

#Habilita els virtual hosts 
cd /etc/apache2/sites-available
a2ensite taller.conf
a2ensite tenda.conf

#Reinicia el servei apache
service apache2 restart
