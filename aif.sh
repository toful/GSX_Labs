#!/bin/bash

#####################################################################################
# Autors: Cristòfol Daudèn i Aleix Mariné											#
# Data d'implementació: 7/2/2018													#
# Versió 1.0																		#
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

if [ "$1" = "-h" ]; then
	ayuda
	exit 0
fi
if [ $# -lt 5 ]; then
	echo "No has passat el nombre adequat de paràmetres! Mostrant la ajuda..."
	ayuda
	exit 1
else
	echo -e "\nauto $1\niface $1 inet static\n\taddress $2\n\tnetmask $3\n\tnetwork $4\n\tgateway $5" >> interfaces 
	exit 0
fi