#!/bin/bash

<<INSTRUCCIONS
Es vol fer un script que s'executi en el moment en que un usuari entra al sistema i
l'informi de l'espai de disc que s'està utilitzant sota del seu directori d'entrada. Volem
usar la comanda du per a calcular l'espai del disc que ocupa.
INSTRUCCIONS

###############################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                                           
# Data d'implementació: 2/5/2018                                                  
# Versio 1.0                                                                        
# Permisos: permisos per a modificar /etc/profile                                   
# Descripció i paràmetres: Es vol implementar un script que s'executi en el moment en que un
# usuari entra al sistema i l'informi de l'espai de disc que s'està utilitzant sota del seu   
# directori d'entrada. Volem usar la comanda du per a calcular l'espai del disc que ocupa.
#
# Aquest script no necessita arguments, excepte el d'ajuda que es opcional.
# 
# Aquest script instal·la una sola línia de codi al fitxer /etc/profile que 
# mostra una notificació d'escriptori quan l'usuari es logueja.
###############################################################################

function ayuda {
	echo "
###############################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                                           
# Data d'implementació: 13/3/2018                                                   
# Versio 1.0                                                                        
# Permisos: permisos per a modificar /etc/profile                                   
# Descripció i paràmetres: Es vol implementar un script que s'executi en el moment en que un
# usuari entra al sistema i l'informi de l'espai de disc que s'està utilitzant sota del seu   
# directori d'entrada. Volem usar la comanda du per a calcular l'espai del disc que ocupa.
#
# Aquest script no necessita arguments, excepte el d'ajuda que es opcional.
# 
# Aquest script instal·la una sola línia de codi al fitxer /etc/profile que 
# mostra una notificació d'escriptori quan l'usuari es logueja.
###############################################################################
"
}

# Comprovem existencia de directoris
if [ ! -d "/usr/local/infomem" ]; then
	echo -e "\nWarning, directory /usr/local/infomem does not exist. Creating..."
	mkdir /usr/local/infomem
fi

# copiem s'cript en aquest directori mantenint permisos
cp -p infomem.sh /usr/local/infomem

# carreguem execució de l'script a ~/.profile si no es troba ja carregada
if [ -z "$(more /etc/profile | grep /usr/local/infomem/infomem.sh)" ]
then
	echo '/usr/local/infomem/infomem.sh' >> /etc/profile
fi




