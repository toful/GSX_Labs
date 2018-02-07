#!/bin/bash

#####################################################################################
# Autors: Cristòfol Daudèn i Aleix Marine                                           #
# Data d'implementació: 7/2/2018                                                    #
# Versio 1.0                                                                        #
# Aquest script necessita permisos per a modificar el fitxer rebut per paràmetre.   # 
# Si no existeix, el crearà buit.                                                   #
# Descripció i paràmetres: Aquest script buida el fitxer rebut per paràmetre        #
# - Argument 1: Ruta completa fins al fitxer                                        #					#####################################################################################

function ayuda {
	echo "
###############################################################################
# Autors: Cristòfol Daudèn i Aleix Mariné                                     #
# Data d'implementació: 7/2/2018                                              #
# Versió 1.0                                                                  #
# Aquest script necessita permisos per a modificar el fitxer rebut per        #
# paràmetre.                                                                  #
# Descripció i paràmetres: Aquest script buida el fitxer rebut per paràmetre. #
# Si no existeix, el crearà buit.                                             #
# - Argument 1: Ruta completa fins al fitxer                                  #
###############################################################################
"
}

if [ "$1" = "-h" ]; then
	ayuda
	exit 0
fi
if [ $# -lt 1 ]; then
	echo "No has passat el nombre adequat de paràmetres! Mostrant la ajuda..."
	ayuda
	exit 1
else
	> $1
	exit 0
fi
