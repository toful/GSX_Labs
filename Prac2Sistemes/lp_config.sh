#!/bin/bash

<<INSTRUCCIONS
Es vol creat un script anomenat lp que supleixi lactual comanda lp (per a enviar a
imprimir un document) i que a mes de les opcions normals que accepta la comanda lp
estàndard, quan s’esculli la impressora virtualImpre, usant lopció -d de la comanda,
ens demani una paraula clau (emmaiatzemada per cada usuari), comprovi la validesa i
en cas que sigui correcta limprimeixi, si la clau es incorrecta, ha de donar un missatie
derror.
NOTA: El ftxer de paraules clau estarà en el directori /usr/local/secret i ha d’estar
format pel login i la paraula clau. Opcionalment les paraules clau shaurien dencriptar.
Heu de tenir en compte que la paraula clau no ha de sortir escrita per pantalla (heu
dusar la comanda stty per activar o desactivar lecho de pantalla)
INSTRUCCIONS

###############################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                                           
# Data d'implementació: 18/4/2018                                                   
# Versio 1.0                                                                        
# Permisos:	necessita els permisos per a escriure en la carpeta usr/local i per 
# escriure a /etc/bash.bashrc, pel que necessitarem permisos de root.                                   
# Descripció i paràmetres: Es vol implementar un script que posi a punt una comanda
# anomenada lp, que tingui les mateixes opcions que la comanda lp que ja es troba
# en el sistema pero que quan s'specifiqui el parametre -d acompanyat de virtualImpre
# sol·liciti una contrassenya (propia de cada usuari).
#
# L'script comprovara que la contrassenya introduida per l'usuari es la mateixa
# que esta definida per a aquell usuari en el fitxer /usr/local/secret.
# Si es correcta la comanda passa a executar-se, sinó mostra error.
# 
# Aquest fitxer tindra en cada linea el nom d'usuari i la seva contrassenya,
# separats per punt i coma.
# 
# La constrassenya no sera mostrada per la pantalla.
#
# Aquest script no necessita arguments, excepte el d'ajuda que es opcional
###############################################################################

function ayuda {
	echo "
###############################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                                           
# Data d'implementació: 18/4/2018                                                   
# Versio 1.0                                                                        
# Permisos:	necessita els permisos per a escriure en la carpeta usr/local, per tant utilitzarem
# super-usuari.                                   
# Descripció i paràmetres: Es vol implementar un script que posi a punt una comanda
# anomenada lp, que tingui les mateixes opcions que la comanda lp que ja es troba
# en el sistema pero que quan s'specifiqui el parametre -d acompanyat de virtualImpre
# sol·liciti una contrassenya (propia de cada usuari).
#
# L'script comprovara que la contrassenya introduida per l'usuari es la mateixa
# que esta definida per a aquell usuari en el fitxer /usr/local/secret.
# Si es correcta la comanda passa a executar-se, sinó mostra error.
# 
# Aquest fitxer tindra en cada linea el nom d'usuari i la seva contrassenya,
# separats per punt i coma.
# 
# La constrassenya no sera mostrada per la pantalla.
#
# Aquest script no necessita arguments, excepte el d'ajuda que es opcional
##############################################################################
"
}


PASSWDFILE=/usr/local/secret
LP_PATH=/usr/local/lp

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
	export PATH="$LP_PATH:$PATH" 
	echo -e "\nexport PATH=$PATH" >> /etc/bash.bashrc
fi

# copiem l'script lp a LP_PATH
cp lp $LP_PATH

echo "Introdueix la clau mestra del fitxer de contrassenyes"
read PSW
if [ -z $PSW ]
then
	echo "has deixat el password buit. S'assignara automaticament a \"gsx2018\""
	PSW="gsx2018"
fi

newusers=""

echo "Introdueix ara els usuaris i passwords. Deixals buits per a parar"
while :
do
	echo "Introdueix nom d'usuari: "
	read user
	echo "Introdueix password: "
	read pass
	if [ -z $user ] || [ -z $pass ]; then
		break
	fi
	newusers=$(echo "$newusers
$user;$pass")
done

echo -e "$newusers" >> secret.decrypt
more secret.decrypt | openssl enc -aes-128-cbc -a -salt -pass pass:$PSW > /usr/local/secret
rm secret.decrypt

# Afegim el password al script per a pugui desencriptar
sed -i "s/-pass pass:/-pass pass:$PSW/g" /usr/local/lp/lp
