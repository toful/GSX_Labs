#!/bin/bash
poni="Es vol implementar un script altausers per donar d’alta varis usuaris
de manera simple:
• El login de l’usuari serà: el nom, i la primera lletra del cognom1
i la primera lletra del cognom 2. En cas d’empat, es posarà un
número darrera que s’anirà incrementant.
• El passwd serà el número de telèfon.
• Els directoris d’entrada estaran sota el directori /usuaris i es
diran con el seu login.
La resta d’informació s’ha d’agafar dels següents 2 fitxers:
• Un arxiu de configuració /root/conf/.usuaris on hi haurà la
configuració general de la nostra empresa. El format de l’arxiu
serà el següent:
• path absolut del directori on hi ha els fitxers de
configuració inicial que s’han de copiar al directori
d’entrada dels usuaris
• uidmin-uidmax
• gidmin-gidmax
• shell que es posarà a l’usuari
• Un arxiu que es passarà per paràmetre amb la informació de
l’usuari que vulguem crear. El format de l’arxiu serà el següent:
(Tots els camps estaran separats per , i poden contenir qualsevol
tipus de caràcter)
DNI, Nom, Cognom1, Cognom2, telèfon, grup1, cpu
assignada, grup2, cpu assignada, ...
• El primer grup que passem serà el seu grup primari, la resta
de grups han de ser secundaris.
• Darrera del grup hi ha en quina cpu volem que s’executi
l’usuari quan estigui en el grup actiu indicat.
• L’script s’ha de deixar preparat per tal de que quan es donin
d’alta nous usuaris es pugui tornar a executar i afegeixi
únicament els nous usuaris, sense modificar els ja existents. Per
tal d’implementar l’script, s’han d’utilitzar les comandes més
adients de la distribució de debian dels laboratoris.

echo -e $DNI $NAME $SUR1 $SUR2 $TLFN $GRUPS $aux
echo -e  $shell $skel $uidmin $uidmax $gidmin $gidmax
"


function ayuda {
	echo "
###############################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                                           
# Data d'implementació: 13/3/2018                                                   
# Versio 1.0                                                                        
# Permisos:	root						                                   
# Descripció i paràmetres: 							
###############################################################################
"
}

CONF_PATH=/root/conf/.usuaris
LOGIN_DEFAULT=/etc/login.defs
BASE_DIR=/usuaris

getline () { awk -vlnum=${1} 'NR==lnum {print; exit}'; }

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
# comprovar els parametres i assignar per defecte..if [ $uidmin 
num=$(grep ^"UID_MIN" /etc/login.defs | cut -d" " -f2)
sed -e "/UID_MIN/ s/$num/$uidmin/g" "$LOGIN_DEFAULT" > "$LOGIN_DEFAULT"

uidmax=$(more $CONF_PATH | getline 2 | cut -d "-" -f2)
if [ -z $uidmax ]; then
	uidmax=1000
fi

num=$(grep ^"UID_MAX" /etc/login.defs | cut -d" " -f2)
sed -e "/UID_MAX/ s/$num/$uidmax/g" "$LOGIN_DEFAULT" > "$LOGIN_DEFAULT"

gidmin=$(more $CONF_PATH | getline 3 | cut -d "-" -f1)
if [ -z $gidmin ]; then
	gidmin=200
fi
num=$(grep ^"GID_MIN" /etc/login.defs | cut -d" " -f2)
sed -e "/GID_MIN/ s/$num/$gidmin/g" "$LOGIN_DEFAULT" > "$LOGIN_DEFAULT"

gidmax=$(more $CONF_PATH | getline 3 | cut -d "-" -f2)
if [ -z $gidmax ]; then
	gidmax=2000
fi
num=$(grep ^"GID_MAX" /etc/login.defs | cut -d" " -f2)
sed -e "/GID_MAX/ s/$num/$gidmax/g" "$LOGIN_DEFAULT" > "$LOGIN_DEFAULT"

shell=$(more $CONF_PATH | getline 4)
if [ ! -f $shell ]; then
	shell="/bin/bash"
fi

echo "Configuration OK"
echo -e "$CONF_PATH $LOGIN_DEFAULT $BASE_DIR"

# Add user/s
while IFS="," read DNI NAME SUR1 SUR2 TLFN GROUPS
do
	echo "algo"
	USR_NAME="$NAME${SUR1:0:1}${SUR2:0:1}"

	# Check if user is already registered
	if [ ! -z $(cat /etc/passwd | grep -w $DNI) ]; then #Si la linia on trobem el DNI de 
		echo "The user with DNI $DNI is already registered." >&2
		continue # instruccio break; i passem al seguent user
  	fi
  	
  	cont=0
  	echo -e "Registrant l'usuari $DNI amb nom d'usuari predefinit $USR_NAME"
	# Creacio del nom d'usuari
	id $USR_NAME > /dev/null 2> /dev/null	
	while [ "$?" -eq "0" ]; do # Mirem si aux es un nom adequat i sino incrementem comptador i generem nou nom
		aux="$USR_NAME$cont"
		cont=$((cont + 1))
		echo $aux
		id $aux > /dev/null 2> /dev/null	
	done

	echo "Name created"
	# tractem el primer grup de manera especial degut a que es el grup primari
	if [ ! -z $GROUPS ]; then
		PRIMARY_GROUP=$(echo -e $GROUPS | cut -d ',' -f1)
		groupadd $PRIMARY_GROUP > /dev/nul 2> /dev/nul
		if [ "$?" -eq "0" ]; then
			echo -e "\nGroup $PRIMARY_GROUP has been created"
		else
			echo -e "\nGroup $PRIMARY_GROUP already exists"
		fi
		PRIMARY_CPU=$(echo -e $GROUPS | cut -d ',' -f2)
		#./limit_cpu_use.sh $PRIMARY_GROUP $PRIMARY_CPU
	fi

	SECONDARY_GROUPS_LIST=""
	LIST_GROUPS_CPU=$(echo $GROUPS | cut -d ',' -f3-)
	while [ ! -z $LIST_GROUPS_CPU ]; do
		var=$(echo $LIST_GROUPS_CPU | cut -d ',' -f1)
		groupadd $var > /dev/nul 2> /dev/nul
		if [ "$?" -eq "0" ]; then
			echo -e "\nGroup $var has been created"
		else
			echo -e "\nGroup $var already exists"
		fi
		SECONDARY_GROUPS_LIST="$SECONDARY_GROUPS_LIST,$var"
		echo $SECONDARY_GROUPS_LIST
		CPU=$(echo $LIST_GROUPS_CPU | cut -d ',' -f2)
		LIST_GROUPS_CPU=$(echo $LIST_GROUPS_CPU | cut -d ',' -f3-)
		#./limit_cpu_use.sh $GROUP $CPU
	done

	SECONDARY_GROUPS_LIST="${SECONDARY_GROUPS_LIST:1}" # eliminem la coma inicial

	# b basename path a on situarem la nostra carpeta (vindria a er home per defecte)
	# c password
	# d directori de l'usuari sol ser /home/[nom usuari]
	# g grup primari de l'usuari (ha d'existir)
	# G grup de directoris secundaris (separats per coma)
	# k directori esquelet (es copiara tot el contingut d'aquest directori al direcotori d'entrada)
	# m força la creacio de del direcotri de l'usuari 
	# p password
	# s shell per defecte
	
	useradd -b "/usuaris" -c "$DNI" -d "/usuaris/$aux" -g "$PRIMARY_GROUP" -G "$SECONDARY_GROUPS_LIST" -k "$skel" -m -p "$TLFN" -s "$shell" "$aux"
	#echo "$aux:$TLFN" | chpasswd
done < $1
exit 0
