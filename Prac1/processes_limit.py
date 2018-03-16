#!/bin/bash

#####################################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marin                                         
# Data d'implementació:  5/3/2018                                                  
# Versio 1.0                                                                        
# Permisos:									                                       
# Descripció i paràmetres: Script que atura (o repren) els processos que consumeixen recursos per sobre d'un rang.           
# -Argument 1: Aturar (-s) / Renaurdar (-r) / Ajuda (-h) 									#####################################################################################

#Obtenim el directori on s'ubica l'Script per guardar el fitxer auxiliar dels processos suspesos.
BASEDIR=$(dirname $0)

function ayuda {
	echo "
###############################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marin                                         
# Data d'implementació: 5/3/2018                                                   
# Versio 1.0                                                                        
# Permisos:									                                        
# Descripció i paràmetres: Script que atura (o repren) els processos que consumeixen recursos per sobre d'un rang.                     
# -Argument 1: Aturar (-s) / Renaurdar (-r) / Ajuda (-h)									
###############################################################################
"
}


if [ "$1" = "-h" ]; then
	ayuda
	exit 0
fi

#mirem que s'hagi introduit l'argument.
if [ $# -lt 1 ] 
then
	echo "ERROR, you have to indroduce one argumnet" >&1
	ayuda
	exit 1
fi

#Suspendre processos. Argument "-s".
if [ "$1" = "-s" ] 
	then
	echo "The following processes will be suspended."
	ps aux | awk '$10>="5:00"||$5>=1000000{print $0}' # Filtra els processos que consumeixin mes de 1GB de mem o que hagin estat en execucio mes de 5 min, tot imprimint-los.
	processes=($(ps aux | awk '$10>="5:00"||$5>=1000000{print $2}')) # Filtra els processos amb el mateix criteri i guardar-los en un array.
	echo ${processes[@]} > $BASEDIR/suspended_process.txt  # Guarda l'array en un fitxer.
	for i in "${processes[@]:1}" 
	do 
		kill -STOP $i # Suspendre cada proces de l'Array.
	done
#Suspendre processos. Argument "-r".
elif [ "$1" = "-r" ] 
then
	echo "The following processes (listed by PID) will be resumed."
	mapfile -t processes < $BASEDIR/suspended_process.txt  # Obten l'array de processos suspesos a partir del fitxer de text.
	processes=($(echo ${processes[0]} | tr " " "\n"))
	for i in "${processes[@]:1}"
	do 
		kill -CONT $i # Repen cada proces de l'Array.
		echo $i # Mostra el PID de cada proces repres
	done
else # Gesstio d'errors si s'introdueix un argument invalid.
	echo "ERROR, you have to introduce a valid argument: -s or -r"
	exit 1
fi

exit 0
