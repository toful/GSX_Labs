#!/bin/bash

<<INSTRUCCIONS
Monitoritzeu els recursos (memòria, cpu i disc) amb la comanda vmstat i engegant
diferents programes per a fer un ús intensiu de memòria, de processador i de disc.
Creeu diferents programes en C o scripts per tal de fer un ús intensiu del processador,
de la memòria i del disc de manera individual.
Monitoritzeu el sistema, executant cada un dels programes de manera individual i
comprovant com afecten a les comandes de monitorització́ (vmstat, iostat)
INSTRUCCIONS

###############################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                                           
# Data d'implementació: 27/4/2018                                                   
# Versio 1.0                                                                        
# Permisos:	No necessita permisos especials.
# Descripció i paràmetres: Es vol implementar un conjunt de benchmarks programats
# en C per a que serveixin de prova per a la monitoritzacio amb la maquina amb la 
# que estem treballant.
#
# Tindrem un benchmark per a memoria, cpu i disc. Duen a terme una reserva de
# memoria intensiva utilitzant el programa malloc, duent a terme un for de milions 
# d'iteracions i finalment el programa de disc esta continuament escribint a disc
# amb la mida de bloc passada per paràmetre. 
#
# Després d'executar aquests benchmark de manera individual (durant 10 segons) iniciem 
# els programes vmstat i iostat que comencen a monitoritzar diferents paràmetres del 
# sistema.
#
# Aquest script automatitza i refina les dades obtingudes en aquest últim procés,
# mostrant aquells camps més interessants, escribint-los de manera ordenada en el 
# fitxer log.txt.
#
# L'únic paràmetre disponible és el de l'ajuda
###############################################################################

function ayuda {
	echo "
###############################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                                           
# Data d'implementació: 27/4/2018                                                   
# Versio 1.0                                                                        
# Permisos:	No necessita permisos especials.
# Descripció i paràmetres: Es vol implementar un conjunt de benchmarks programats
# en C per a que serveixin de prova per a la monitoritzacio amb la maquina amb la 
# que estem treballant.
#
# Tindrem un benchmark per a memoria, cpu i disc. Duen a terme una reserva de
# memoria intensiva utilitzant el programa malloc, duent a terme un for de milions 
# d'iteracions i finalment el programa de disc esta continuament escribint a disc
# amb la mida de bloc passada per paràmetre. 
#
# Després d'executar aquests benchmark de manera individual (durant 10 segons) iniciem 
# els programes vmstat i iostat que comencen a monitoritzar diferents paràmetres del 
# sistema.
#
# Aquest script automatitza i refina les dades obtingudes en aquest últim procés,
# mostrant aquells camps més interessants, escribint-los de manera ordenada en el 
# fitxer log.txt.
#
# L'únic paràmetre disponible és el de l'ajuda
###############################################################################"
}

#Mirem parametre d'ajuda
if [ "$1" = "-h" ]; then
	ayuda
	exit 0
fi

echo "		RESULTATS" > log.txt
echo "......................................." >> log.txt
make all

echo "CPU TEST" >> log.txt
echo "VMSTAT" >> log.txt
timeout 10 ./cpu &
vmstat -an 1 10 | tail -n +3 | awk {'print $13 " % CPU"'} >> log.txt
echo "IOSTAT" >> log.txt
timeout 10 ./cpu &
iostat -c 1 10 | tail -n +3 | tr -s '\n' | grep -v -e "^avg-cpu" | awk {'print $1" % CPU"'} >> log.txt

echo "RAM TEST" >> log.txt
echo "VMSTAT" >> log.txt
timeout 10 ./ram &
vmstat -an 1 10 | tail -n +3 | awk {'print $4" kB lliures"'} >> log.txt


echo "DISK TEST" >> log.txt
echo "VMSTAT" >> log.txt
timeout 10 ./disk test 5120 &
vmstat -dn 1 10 | tail -n +3 | awk {'print $1"\tReads: "$2" operacions read\t"  "Writes: "$6" operacions write"'} >> log.txt
echo "IOSTAT" >> log.txt
timeout 10 ./disk test 5120 &
iostat -d 1 10 | tail -n +3 | grep -v -e "^Device" | tr -s '\n' | awk {'print $1"\tReads: "$5" kB\t"  "Writes: "$6 " kB"'} >> log.txt
rm -f test

echo "Finished"


