#!/bin/bash

<<INSTRUCCIONS
Es vol fer un script que s'executi en el moment en que un usuari entra al sistema i
l'informi de l'espai de disc que s'està utilitzant sota del seu directori d'entrada. Volem
usar la comanda du per a calcular l'espai del disc que ocupa.
INSTRUCCIONS

###############################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                                           
# Data d'implementació: 2/5/2018                                                   5
# Versio 1.0                                                                        
# Permisos: permisos per a crear un fitxer a $HOME                                   
# Descripció i paràmetres: Es vol implementar un script que s'executi en el moment en que un       # usuari entra al sistema i l'informi de l'espai de disc que s'està utilitzant sota del seu   
# directori d'entrada. Volemusar la comanda du per a calcular l'espai del disc que ocupa.
#
# Aquest script no necessita arguments, excepte el d'ajuda que es opcional
###############################################################################

function ayuda {
	echo "
###############################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                                           
# Data d'implementació: 13/3/2018                                                   
# Vers
"
}

getline () { awk -vlnum=${1} 'NR==lnum {print; exit}'; }

#Mirem parametre d'ajuda
if [ "$1" = "-h" ]; then
	ayuda
	exit 0
fi

# Comprovem existencia de directoris
# considerem que el directori /usr/local ja existeixen
if [ ! -f "/usr/local/secret" ]; then
	echo -e "\nError, file /usr/local/secret does not exist. Creating..."
	touch /usr/local/secret
fi

# Comprovem existencia de directoris
if [ ! -d "/usr/local/lp" ]; then
	echo -e "\nError, directory /usr/local/lp does not exist. Creating..."
	mkdir /usr/local/lp
fi

# Modifiquem la variable PATH si cal. Ara buscara la comanda lp en /usr/local/lp en primer lloc
if [ $(echo $PATH | cut -d ':' -f1) != $LP_PATH ]
then
	export PATH="$LP_PATH:$PATH" #TODO la variable path que es modifica es la del usuari que executa l'script (root)
	echo -e "\nPATH=$PATH" >> $HOME/.bashrc
	echo -e "\nexport PATH" >> $HOME/.bashrc
fi

# copiem l'script lp a LP_PATH
cp lp $LP_PATH

