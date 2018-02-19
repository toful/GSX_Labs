#!/bin/bash

#####################################################################################
# Autors: Cristòfol Daudèn i Aleix Marine                                           #
# Data d'implementació: 7/2/2018                                                    #
# Versio 1.0                                                                        #
# Permisos: Aquest script necessita permisos per a llegir el fitxer rebut per       #
# paràmetre i permisos per a llegir els fitxers indicats a dins del fitxer.         #
# per paràmetre.                                                                    #
# Descripció i paràmetres: Retorna el propietari, grup i permisos dels fitxers els  #
# paths dels quals es troben en cada línia del fitxer d'entrada.                    #
# -Argument 1: Ruta completa fins al fitxer que conté la ruta a la resta de fitxers #
#####################################################################################

function ayuda {
	echo "
###############################################################################
# Autors: Cristòfol Daudèn i Aleix Mariné                                     #
# Data d'implementació: 7/2/2018                                              #
# Versió 1.0                                                                  #
# Permisos: Aquest script necessita permisos per a llegir el fitxer rebut per #
# paràmetre i permisos per a llegir els fitxers indicats a dins del fitxer.   #
# per paràmetre.                                                              #
# Descripció i paràmetres: Retorna el propietari, grup i permisos dels fitxers#
# els paths dels quals es troben en cada línia del fitxer d'entrada           #
# -Argument 1: Ruta completa fins al fitxer que conté la ruta a la resta de   #
# fitxers                                                                     #
###############################################################################
"
}

if [ "$1" = "-h" ]; then
	ayuda
	exit 0
fi

if [ $# -lt 1 ]
then 
	echo "ERROR, no file detected"
	ayuda
	exit 1
fi

IFS=$'\n'
for file in $(cat $1)
do
	echo $file $(stat -c "%U %G %a" $file)
done
exit 0
