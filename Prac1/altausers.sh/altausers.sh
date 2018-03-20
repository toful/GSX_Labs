#!/bin/bash

###############################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                                           
# Data d'implementació: 13/3/2018                                                   
# Versio 1.0                                                                        
# Permisos:	root						                                   
# Descripció i paràmetres: Es vol implementar un script altausers per donar
# d’alta varis usuaris en una sola execució. La informació dels usuaris serà 
# rebuda per paràmetre a través d'un fitxer				
###############################################################################

function ayuda {
	echo "
###############################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                                           
# Data d'implementació: 13/3/2018                                                   
# Versio 1.0                                                                        
# Permisos:	root						                                   
# Descripció i paràmetres: Es vol implementar un script altausers per donar
# d’alta varis usuaris en una sola execució. La informació dels usuaris serà 
# rebuda per paràmetre a través d'un fitxer				
###############################################################################
"
}

getline () { awk -vlnum=${1} 'NR==lnum {print; exit}'; }

CONF_PATH=/root/conf/.usuaris
LOGIN_DEFAULT=/etc/login.defs
BASE_DIR=/usuaris

#mirem que s'hagin introduit tots els arguments
if [ $# -lt 1 ]; then
	echo "Error, you need to introduce an argument!"
	ayuda
	exit 1
fi

#Mirem parametre d'ajuda
if [ "$1" = "-h" ]; then
	ayuda
	exit 0
fi

# Comprovem que es tinguin permisos de root
if [ $(whoami) != "root" ]; then
	echo "ERROR, Root permissions needed"
	exit 1
fi

# Comprovem existencia de directoris
if [ ! -d "/root" ]; then
	echo -e "\nError, directory /root does not exist. Creating..."
	mkdir /root
fi

if [ ! -d "/root/conf" ]; then
	echo -e "\nError, directory /root/conf does not exist. Creating..."
	mkdir /root/conf
fi

if [ ! -f "/root/conf/.usuaris" ]; then
	read
	echo -e "\nError, file /root/conf/.usuaris does not exist. Creating..."
	echo "" > /root/conf/.usuaris
	echo -e "\nNow /root/conf/.usuaris is empty, introduce correct data as specified in headers and execute the script later."
	exit 1
fi

if [ ! -f "$1" ]; then
	echo -e "\nError, file $1 specified in argument, does not exist or is not a valid file. " 
	echo -e "\nSpecify a valid file and execute this script"
	exit 2
fi

if [ ! -d $BASE_DIR ]; then
	mkdir $BASE_DIR
fi

# reading input from file CONF_PATH and defining limits of uid and gid in login.defs
skel=$(more $CONF_PATH | getline 1)

if [ ! -d $skel ]; then 
	skel="/home"
fi

uidmin=$(more $CONF_PATH | getline 2 | cut -d "-" -f1)
if [ -z $uidmin ]; then
	uidmin=100
fi
# comprovar els parametres i assignar per defecte.
num=$(grep ^"UID_MIN" /etc/login.defs | tr -s "\t" | tr '\t' ' ' | tr -s " " | cut -d ' ' -f2)
sed -i "/UID_MIN/ s/$num/$uidmin/g" "$LOGIN_DEFAULT"

read
uidmax=$(more $CONF_PATH | getline 2 | cut -d "-" -f2)
if [ -z $uidmax ]; then
	uidmax=1000
fi


num=$(grep ^"UID_MAX" /etc/login.defs | tr -s "\t" | tr '\t' ' ' | tr -s " " | cut -d ' ' -f2)
sed -i "/UID_MAX/ s/$num/$uidmax/g" "$LOGIN_DEFAULT"


gidmin=$(more $CONF_PATH | getline 3 | cut -d "-" -f1)
if [ -z $gidmin ]; then
	gidmin=200
fi
num=$(grep ^"GID_MIN" /etc/login.defs | tr -s "\t" | tr '\t' ' ' | tr -s " " | cut -d ' ' -f2)
sed -i "/GID_MIN/ s/$num/$gidmin/g" "$LOGIN_DEFAULT"

gidmax=$(more $CONF_PATH | getline 3 | cut -d "-" -f2)
if [ -z $gidmax ]; then
	gidmax=2000
fi
num=$(grep ^"GID_MAX" /etc/login.defs | tr -s "\t" | tr '\t' ' ' | tr -s " " | cut -d ' ' -f2)
sed -i "/GID_MAX/ s/$num/$gidmax/g" "$LOGIN_DEFAULT"

shell=$(more $CONF_PATH | getline 4)
if [ ! -f $shell ]; then
	shell="/bin/bash"
fi

# Add user/s
while IFS="," read DNI NAME SUR1 SUR2 TLFN GRUPS
do
	USR_NAME="$NAME${SUR1:0:1}${SUR2:0:1}"
	aux="$USR_NAME"
	cont=0
	
	# Check if user is already registered
	if [ ! -z $(cat /etc/passwd | grep -w $DNI) ]; then #Si la linia on trobem el DNI de 
		echo "The user with DNI $DNI is already registered." >&2
		continue # instruccio break; i passem al seguent user
  	fi
  	
	# Creacio del nom d'usuari
	id $aux > /dev/null 2> /dev/null	
	
	while [ "$?" -eq "0" ]; do # Mirem si aux es un nom adequat i sino incrementem comptador i generem nou nom
		aux="$USR_NAME$cont"
		cont=$((cont + 1))
		id $aux > /dev/null 2> /dev/null	
	done

	# tractem el primer grup de manera especial degut a que es el grup primari
	if [ ! -z $GRUPS ]; then
		PRIMARY_GROUP=$(echo -e $GRUPS | cut -d ',' -f1)
		groupadd -f $PRIMARY_GROUP
		PRIMARY_CPU=$(echo -e $GRUPS | cut -d ',' -f2)
		#./limit_cpu_use.sh $PRIMARY_GROUP $PRIMARY_CPU
	fi
	# creem la resta de grups de cpu amb la cpu que ens passen aprofitant la implementacio de l'altre script
	SECONDARY_GROUPS=""
	GRUPS=$(echo $GRUPS | cut -d ',' -f3-)
	while [ ! -z $GRUPS ]; do
		GROUP=$(echo $GRUPS | cut -d ',' -f1)
		groupadd -f $GROUP
		SECONDARY_GROUPS="$SECONDARY_GROUPS,$GROUP"
		CPU=$(echo $GRUPS | cut -d ',' -f2)
		GRUPS=$(echo $GRUPS | cut -d ',' -f3-)
		#./limit_cpu_use.sh $GROUP $CPU
	done

	SECONDARY_GROUPS="${SECONDARY_GROUPS:1}" # eliminem la coma inicial

	# b basename path a on situarem la nostra carpeta (vindria a er home per defecte)
	# c password
	# d directori de l'usuari sol ser /home/[nom usuari]
	# g grup primari de l'usuari (ha d'existir)
	# G grup de directoris secundaris (separats per coma)
	# k directori esquelet (es copiara tot el contingut d'aquest directori al direcotori d'entrada)
	# m força la creacio de del direcotri de l'usuari 
	# p password
	# s shell per defecte
	
	useradd -b "/usuaris" -c "$DNI" -d "/usuaris/$aux" -g "$PRIMARY_GROUP" -G "$SECONDARY_GROUPS" -k "$skel" -m -p "$TLFN" -s "$shell" "$aux"
	#echo "$aux:$TLFN" | chpasswd
done < $1
exit 0
