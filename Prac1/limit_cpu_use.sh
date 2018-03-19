#!/bin/bash

#####################################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                                         
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
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                             
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

#comprovem que l'usuari existeixi
id $2 > /dev/null >&2
if [ $? -eq 0 ]
then
	#creem un group per l'usuari
	mkdir /sys/fs/cgroup/cpuset
	mkdir /sys/fs/cgroup/cpuset/$2
	echo $1 > /sys/fs/cgroup/cpuset/$2/cpuset.cpus   
	echo 0 > /sys/fs/cgroup/cpuset/$2/cpuset.mems
	#echo $(ps -ef | grep $$ | tr -s ' ' | sed -n '1p' | cut -d ' ' -f3) > /sys/fs/cgroup/cpuset/$2/tasks
	echo $(ps -ef | egrep -e "^$2.*bash" | tr -s ' ' | sed -n '1p' | cut -d ' ' -f3) > /sys/fs/cgroup/cpuset/$2/tasks
	
	exit 0
else
	echo "ERROR, user doesn't exist" >&2
	ayuda
	exit 1
fi
