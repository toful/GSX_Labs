#!/bin/bash
#Authors:	Crstòfol Daudén Esmel i Aleix Mariné Tena
#Date:		07-02-2018
#Version:	1.0
#Description:	Retorna el propietari, grup i permisos dels fitxers el path dels quals és troba en el fitxer d'entrada
#Arg 1:		Fitxer amb els paths d'altres fitxers


if [ $# -lt 1 ]
then 
	echo ERROR, no file detected >&2
	exit 1
fi

IFS=$'\n'
for file in $(cat $1)
do
	echo $file $(stat -c "%U %G %a" $file)
done
exit 0
