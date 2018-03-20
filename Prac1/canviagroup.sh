#!/bin/bash

#####################################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                                           
# Data d'implementació: 13/3/2018                                                   
# Versio 1.0                                                                        
# Permisos: User								                                   
# Descripció i paràmetres: Aquest script canviara al grup indicat per parametre.
#			   Es restablira al grup prinipal anterior al comandar exit.        
# -Argument 1: Nom del grup al que canviar.							
#####################################################################################

function ayuda {
	echo "
###############################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                                           
# Data d'implementació: 13/3/2018                                                   
# Versio 1.0                                                                        
# Permisos: User								                                   
# Descripció i paràmetres: Aquest script canviara al grup indicat per parametre.
#			   Es restablira al grup prinipal anterior al comandar exit.        
# -Argument 1: Nom del grup al que canviar.								
###############################################################################
"
}

if [ "$1" = "-h" ]; then
	ayuda
	exit 0
fi

#mirem que s'hagin introduit tots els arguments
if [ $# -lt 1 ] 
then
	echo "ERROR, you have to indroduce at least one argumnet" >&2
	ayuda
	exit 1
fi

primary_group=$(id -gn)
groups=($(groups))

if [[ " ${groups[*]} " != *" $1 "* ]]; then
	echo "ERROR, you have indroduced an invalid group name. It must be one of the secondary groups:" >&2
	echo ${groups[@]/$primary_group}
	exit 1
fi

if [[ " $primary_group " = *" $1 "* ]]; then
	echo "ERROR, you have indroduced the current primary group. It must be one of the secondary groups:" >&2
	echo ${groups[@]/$primary_group}
	exit 1
fi

newgrp $1

reset_group () {
	newgrp $primary_group
}

trap "reset_group" EXIT
