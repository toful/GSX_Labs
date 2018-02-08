#!/bin/bash
#Authors:	Crstòfol Daudén Esmel i Aleix Mariné Tena
#Date:		07-02-2018
#Version:	1.0
#Description:	Mira si s'ha canviat algún dels atributs del fitxers descrits en l'argument d'entrada i dona la possibilitat de tornar al seu estat inicial
#Arg 1:		Fitxer amb el nom(path absolut), propietari, grup i permisos de X fitxers

if [ $# -lt 1 ]
then
	echo ERROR, no file as an argument >&2
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
			if [ r='S' -o r='s' ]
			then
				chmod $perm $path
				echo "S'han modificat els permisos a:" $perm
			fi
		fi

		if [ $(stat -c "%U" $path) != $user ]
		then
			echo S'ha detectat que s'ha modificat el propietari, el vols tornar al seu estat anterior: $user"(S/N)"
			read r
			if [ r='S' -o r='s' ]
			then
				chown $user $path
				echo "S'ha modificat el propietari a:" $user
			fi
		fi

		if [ $(stat -c "%G" $path) != $group ]
		then
			echo S'ha detectat que s'han modificat el grup, el vols tornar al seu estat anterior: $group?"(S/N)"
			read r
			if [ r='S' -o r='s' ]
			then
				chgrp $group $path
				echo "S'ha modificat el grup a:" $group
			fi
		fi

	else
		echo ERROR, el fitxer $path ja no existeix
		echo ERROR, el fitxer $path ja no existeix >&2
	fi
done
exit 0
