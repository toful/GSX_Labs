#!/bin/bash

#####################################################################################
# Autors: Cristòfol Daudèn, Aleix Mariné i Josep Marín											#
# Data d'implementació: 7/2/2018													#
# Versió 1.0																		#
# Permisos: L'usuari que executa l'script necesita permisos per a modificar el      #
# fitxer /etc/network/interfaces, que normalment posseeix l'usuari root, pel que    # 
# resulta gairebé imprescindible ser un usuari amb privilegis per a que funcioni.   #  
# Descripció i paràmetres: Aquest script configura una nova interfície de xarxa,    #
# afegint al fitxer /etc/network/interfaces la informació necessaria. Aquesta info  #
# serà aportada pels paràmetres de la següent manera:								#
# - Argument 1: Nom de la interfície											 	#
# - Argument 2: Adreça ip 															#
# - Argument 3: Màscara de xarxa													#
# - Argument 4: Adreça de xarxa														#
# - Argument 5: Porta d'enllaç 														#
#####################################################################################

function ayuda {
	echo "
###############################################################################
# Autors: Cristòfol Daudèn i Aleix Mariné                                     #
# Data d'implementació: 7/2/2018                                              #
# Versió 1.0                                                                  #
# Permisos: L'usuari que executa l'script necesita permisos per a modificar   #
# el fitxer /etc/network/interfaces, que normalment posseeix l'usuari root,   #
# pel que resulta gairebé imprescindible ser un usuari amb privilegis per a   #
# que funcioni.                                                               #  
# Descripció i paràmetres: Aquest script configura una nova interfície de     #
# xarxa, afegint al fitxer /etc/network/interfaces la informació necessaria.  #
# Aquesta info serà aportada pels paràmetres de la següent manera:            #
# - Argument 1: Nom de la interfície                                          #
# - Argument 2: Adreça ip                                                     #
# - Argument 3: Màscara de xarxa                                              #
# - Argument 4: Adreça de xarxa                                               #
# - Argument 5: Porta d'enllaç                                                #
###############################################################################
"
}

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

if [ "$1" = "-h" ]; then
	ayuda
	exit 0
fi
if [ $# -lt 5 ]; then
	echo "No has passat el nombre adequat de paràmetres! Mostrant la ajuda..."
	ayuda
	exit 1
fi

# IPs validations
if ! valid_ip $2; then
	>&2 echo "Format error in IP $2"
	exit
fi
if ! valid_ip $3; then
	>&2 echo "Format error in IP $3"
	exit
fi
if ! valid_ip $4; then
	>&2 echo "Format error in IP $4"
	exit
fi
if ! valid_ip $5; then
	>&2 echo "Format error in IP $5"
	exit
fi

echo -e "\nauto $1\niface $1 inet static\n\taddress $2\n\tnetmask $3\n\tnetwork $4\n\tgateway $5" >> /etc/network/interfaces
exit 0
