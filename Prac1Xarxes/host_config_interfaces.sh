#!/bin/bash
#
#Fitxer de configuració del ROUTER

if [ $# -lt 1 ]
then
	echo "Usem la configuració per defecte"
	echo "ERROR, you have to indroduce four argumnets" >&2

	#Llistem les interfícies de xarxa
	interfaces=$(ip addres show | egrep -e "^[0-9]" | cut -d ':' -f2 | tr -d ' ' | sed '/lo/d')
	i1=$(echo $interfaces | cut -d ' ' -f1)
	#i2=$(echo $interfaces | cut -d ' ' -f2)
	#i3=$(echo $interfaces | cut -d ' ' -f3)
	#addres=10.21.10.4

else
	i1=$1
	#i2=$2
	#i3=$3
	#addres=$4
fi

#revisar la configuració de l'adreça
config="auto lo\niface lo inet loopback
	\n
	\nallow-hotplug $i1\niface $i1 inet static\n\taddress 192.168.17.2\n\tnetmask 255.255.255.0\n\tnetwork 192.168.17.0\n\tbroadcast 192.168.17.255"

#Afegim les rutes que calguin
echo "up ip route add 192.168.16.0/24 via 192.168.17.1/24 dev $1 >> /etc/network/interfaces"

#ip route add default via <ip router extern>? No fa falta no? en teoria el router ja té conexió

#reiniciem els servis de xarxa
/etc/init.d/networking restart

