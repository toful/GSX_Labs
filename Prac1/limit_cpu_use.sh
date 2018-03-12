#!/bin/bash

#####################################################################################
# Autors: Cristòfol Daudèn i Aleix Marine                                           
# Data d'implementació: 21/2/2018                                                   
# Versio 1.0                                                                        
# Permisos:									                                   
# Descripció i paràmetres: 	Script que limita l’ús d’una cpu (entrada per paràmetre)
#							a l’usuari que li passem també per paràmetre            
# -Argument 1: CPU de la que es limitarà l'ús									
# -Argument 2: usuari al que li limitem l'ús a una cpu								
#####################################################################################

function ayuda {
	echo "
###############################################################################
# Autors: Cristòfol Daudèn i Aleix Marine                                           
# Data d'implementació: 21/2/2018                                                   
# Versio 1.0                                                                        
# Permisos:									                                  
# Descripció i paràmetres: 	Script que limita l’ús d’una cpu (entrada per paràmetre)
#							a l’usuari que li passem també per paràmetre            
# -Argument 1: CPU de la que es limitarà l'ús									
# -Argument 2: usuari al que li limitem l'ús a una cpu								
###############################################################################
"
}

if [ "$1" = "-h" ]; then
	ayuda
	exit 0
fi

#mirem que s'hagin introduit tots els arguments
if [ $# -lt 2 ] 
then
	echo "ERROR, you have to indroduce two argumnets" >&2
	ayuda
	exit 1
fi

#mirem que la CPU indicada esigui entre les possibles de la màquina
cpus=$(cat /sys/fs/cgroup/cpuset/cpuset.cpus)
if [[ $1 =~ ^[^$cpus]$ ]] #l'expressio regular no necessita dels delimitadors /^[0-3]$/
then
	echo "ERROR, CPU especified isn't available" >&2
	ayuda
	exit 1
fi

#falta comprovar els usuaris

#creem un group per l'usuari
mkdir /sys/fs/cgroup/cpuset/$2
echo $1 > /sys/fs/cgroup/cpuset/$2/cpuset.cpus
echo 0 > /sys/fs/cgroup/cpuset/$2/cpuset.mems
echo $(ps -ef | grep $$ | tr -s ' ' | sed -n '1p' | cut -d ' ' -f3) > /sys/fs/cgroup/cpuset/$2/tasks

exit 0