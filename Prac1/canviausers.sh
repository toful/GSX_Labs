#!/bin/bash

#####################################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                                          
# Data d'implementació: 13/3/2018                                                   
# Versio 1.0                                                                        
# Permisos:					Root								                                   
# Descripció i paràmetres: 	Aquest script deshabilitarà o habilitarà el compte dels 
#							usuaris que entrem per paràmetre segons estigui habilitat 
#							o deshabilitat.           
# -Argument 1: usuari que deshabilitarem/ habilitarem								
#####################################################################################

function ayuda {
	echo "
###############################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                                           
# Data d'implementació: 13/3/2018                                                   
# Versio 1.0                                                                        
# Permisos:					Root								                                   
# Descripció i paràmetres: 	Aquest script deshabilitarà o habilitarà el compte dels 
#							usuaris que entrem per paràmetre segons estigui habilitat 
#							o deshabilitat.           
# -Argument 1: llistat d'usuaris que deshabilitarem/ habilitarem								
###############################################################################
"
}

if [ "$1" = "-h" ]; then
	ayuda
	exit 0
fi

# Comprovem que es tinguin permisos de root
if [ $(whoami) != "root" ]
then
#if [[ "$EUID" -ne 0 ]]
	echo "ERROR, Root permissions needed" >&2
	exit 1
fi

#mirem que s'hagin introduit tots els arguments
if [ $# -lt 1 ] 
then
	echo "ERROR, you have to indroduce at least one argumnet" >&2
	ayuda
	exit 1
fi

for user in "$@"
do
	#comprovem que l'usuari existeixi
	id $user > /dev/null >&2
	if [ $? -eq 0 ]
	then
		#obtenim el hashcode de l'usuari del fitxer /etc/shadow
		encrypt_pass=$(cat /etc/shadow | egrep $user | cut -d ":" -f2 )
		#comprovem si l'usuari estava bloquejat o no
	    if [ ${encrypt_pass:0:1} == "!" ]
	    then
	    	#desbloquegem l'usuari
	    	passwd -u $user
	    	#usermod -U $user
	    	echo "S'ha desbloquejat l'usuari $user"
	    else
	    	#bloquegem l'usuari
	    	passwd -u $user
	    	#usermod -L $user
	    	echo "S'ha bloquejat l'usuari $user"
	    fi
	else
		echo "ERROR, user $user doesn't exists" >&2
	fi
done
exit 0