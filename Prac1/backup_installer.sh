#!/bin/bash

#####################################################################################
# Autors: Cristòfol Daudèn i Aleix Marine                                           
# Data d'implementació: 21/2/2018                                                    
# Versio 1.0                                                                        
# Permisos: Aquest script necessita permisos per instal·lar un servei               
# Descripció i paràmetres: Aquest instal·la un servei de backup que s'executarà en
# quan s'apagui l'ordinador si estaves en el nivell 3
#####################################################################################

function ayuda {
	echo "
#####################################################################################
# Autors: Cristòfol Daudèn i Aleix Marine                                           
# Data d'implementació: 21/2/2018                                                    
# Versio 1.0                                                                        
# Permisos: Aquest script necessita permisos per instal·lar un servei               
# Descripció i paràmetres: Aquest instal·la un servei de backup que s'executarà en
# quan s'apagui l'ordinador si estaves en el nivell 3
#####################################################################################
"
}

if [ "$1" = "-h" ]; then
	ayuda
	exit 0
fi

cp backup /etc/init.d/backup
systemctl enable backup
systemctl start backup
systemctl status backup