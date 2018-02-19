#!/bin/bash

#####################################################################################
# Autors: Cristòfol Daudèn i Aleix Marine                                           #
# Data d'implementació: 7/2/2018                                                    #
# Versio 1.0                                                                        #
# Permisos: Aquest script necessita permisos per a llegir el fitxer rebut per       #
# paràmetre i permisos per a modificar els permisos dels fitxers indicats a dins    #
# del fitxer rebut per paràmetre (si s'escau)                                       #
# Descripció i paràmetres: Mira si s'ha canviat algún dels atributs del fitxers     #
# descrits en l'argument d'entrada i dona la possibilitat de tornar al seu estat    #
# inicial.                                                                          #
# -Arg1: Fitxer amb el nom(path absolut), propietari, grup i permisos de X fitxers. #
#####################################################################################

function ayuda {
	echo "
###############################################################################
# Autors: Cristòfol Daudèn i Aleix Mariné                                     #
# Data d'implementació: 7/2/2018                                              #
# Versió 1.0                                                                  #
# Permisos: Aquest script necessita permisos per a llegir el fitxer rebut per #
# paràmetre i permisos per a modificar els permisos dels fitxers indicats a   #
# dins del fitxer rebut per paràmetre (si s'escau).                           #
# Descripció i paràmetres: Mira si s'ha canviat algún dels atributs del       #
# fitxers descrits en l'argument d'entrada i dona la possibilitat de tornar al#
# seu estat inicial.                                                          #
# -Arg1: Fitxer amb el nom(path absolut), propietari, grup i permisos de X    #
# fitxers.                                                                    #
###############################################################################
"
}

if [ "$1" = "-h" ]; then
	ayuda
	exit 0
fi

if [ $# -lt 1 ]
then
	echo "ERROR, no file as an argument"
	ayuda
	exit 1
fi

IFS=$'\n'
for file in $(cat $1)
do
	path=$(echo $file | cut -d ' ' -f1)

	#Comprovo si el fitxer existeix
	if [ -e $path ]
	then
		#si existeix comprovo si s'ha modificat algún dels paràmetres i li dino a l'usuari la possibilitat de restaurar-los
		user=$(echo $file | cut -d ' ' -f2)
		group=$(echo $file | cut -d ' ' -f3)
		perm=$(echo $file | cut -d ' ' -f4)
		echo $path $(stat -c "%U %G %a" $path)

		if [ $(stat -c "%a" $path) != $perm ]
		then
			echo S'ha detectat que s'han modificat els permisos, els vols tornar al seu estat anterior: $perm?"(S/N)"
			read r
			if [ r = 'S' -o r = 's' ]
			then
				chmod $perm $path
				echo "S'han modificat els permisos a:" $perm
			fi
		fi

		if [ $(stat -c "%U" $path) != $user ]
		then
			echo S'ha detectat que s'ha modificat el propietari, el vols tornar al seu estat anterior: $user"(S/N)"
			read r
			if [ r = 'S' -o r = 's' ]
			then
				if [ $(whoami) != "root" ]
				then
					echo Per poder canviar el propierari del fitxer necessites permisos de root
				else
					chown $user $path
					echo "S'ha modificat el propietari a:" $user
				fi
			fi
		fi

		if [ $(stat -c "%G" $path) != $group ]
		then
			echo S'ha detectat que s'han modificat el grup, el vols tornar al seu estat anterior: $group?"(S/N)"
			read r
			if [ r = 'S' -o r = 's' ]
			then
				if [ $(whoami) != "root" ]
				then
					echo Per poder canviar el grup del fitxer necessites permisos de root
				else
					chgrp $group $path
					echo "S'ha modificat el grup a:" $group
				fi
			fi
		fi

	else
		echo ERROR, el fitxer $path ja no existeix
		ayuda
	fi
done
exit 0
