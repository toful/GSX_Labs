#!/bin/bash
function display_help(){
	echo -e "This script is for setting up the GSX subjct network configuration\
It has been done for a three machine structure, a router (with three interfaces),a server and client (with only one interface).
You have to indicate wich machine do you want to configure in the first argument:
\trouter\n\tclient\n\tserver
	"
}

function router_config(){
	if [ $# -lt 4 ]
	then
		echo "Usem la configuració per defecte"

		#Llistem les interfícies de xarxa
		interfaces=$(ip addres show | egrep -e "^[0-9]" | cut -d ':' -f2 | tr -d ' ' | sed '/lo/d')
		i1=$(echo $interfaces | cut -d ' ' -f1)
		i2=$(echo $interfaces | cut -d ' ' -f2)
		i3=$(echo $interfaces | cut -d ' ' -f3)

	else
		i1=$2
		i2=$3
		i3=$4
	fi

	config="auto lo\niface lo inet loopback
		\n
		\nauto $i1\niface $i1 inet dhcp
		\n
		\nallow-hotplug $i2\niface $i2 inet static\n\taddress 192.168.16.1\n\tnetmask 255.255.254.0\n\tnetwork 192.168.16.0\n\tbroadcast 192.168.16.255
		\n
		\nallow-hotplug $i3\niface $i3 inet static\n\taddress 192.168.17.1\n\tnetmask 255.255.254.0\n\tnetwork 192.168.17.0\n\tbroadcast 192.168.17.255"

	#Apaguem les interfícies de xarxa
	ifdown $i1 --force
	ifdown $i2 --force
	ifdown $i3 --force

	#escribim canvis en el fitxer /etc/network/interfaces
	echo -e $config > /etc/network/interfaces

	#Activem el forwarding
	echo 1 >/proc/sys/net/ipv4/ip_forward

	#reiniciem les interficies de xarxa
	ifup $i1
	ifup $i2
	ifup $i3

	#obtenim la ip amb conexio a internet del router
	addres=$(hostname -I | cut -d ' ' -f1) 

	#permetem el tràfic cap a l'exterior
	iptables -I INPUT -j ACCEPT
	iptables -t nat -A POSTROUTING -s 192.168.16.0/24 -j SNAT --to $addres
	iptables -t nat -A POSTROUTING -s 192.168.17.0/24 -j SNAT --to $addres
}

function client_config(){
	if [ $# -lt 2 ]
	then
		echo "Usem la configuració per defecte"

		#Llistem les interfícies de xarxa
		interfaces=$(ip addres show | egrep -e "^[0-9]" | cut -d ':' -f2 | tr -d ' ' | sed '/lo/d')
		i1=$(echo $interfaces | cut -d ' ' -f1)

	else
		i1=$2
	fi

	config="auto lo\niface lo inet loopback
		\n
		\nallow-hotplug $i1\niface $i1 inet static\n\taddress 192.168.17.2\n\tnetmask 255.255.254.0\n\tnetwork 192.168.17.0\n\tbroadcast 192.168.17.255"

	ifdown $i1 --force

	#escribim canvis en el fitxer /etc/network/interfaces
	echo -e $config > /etc/network/interfaces

	#Afegim les rutes que calguin
	echo "up ip route add 192.168.16.0/24 via 192.168.17.1 dev $i1" >> /etc/network/interfaces
	echo "up ip route add default via 192.168.17.1" >> /etc/network/interfaces

	ifup $i1
}

function server_config(){
	if [ $# -lt 2 ]
	then
		echo "Usem la configuració per defecte"
		echo "ERROR, you have to indroduce an argumnet" >&2

		#Llistem les interfícies de xarxa
		interfaces=$(ip addres show | egrep -e "^[0-9]" | cut -d ':' -f2 | tr -d ' ' | sed '/lo/d')
		i1=$(echo $interfaces | cut -d ' ' -f1)

	else
		i1=$2
	fi

	config="auto lo\niface lo inet loopback
		\n
		\nallow-hotplug $i1\niface $i1 inet static\n\taddress 192.168.16.2\n\tnetmask 255.255.254.0\n\tnetwork 192.168.16.0\n\tbroadcast 192.168.16.255"

	ifdown $i1 --force

	#escribim canvis en el fitxer /etc/network/interfaces
	echo -e $config > /etc/network/interfaces

	#Afegim les rutes que calguin
	echo "up ip route add 192.168.17.0/24 via 192.168.16.1 dev $i1" >> /etc/network/interfaces
	echo "up ip route add default via 192.168.16.1" >> /etc/network/interfaces

	ifup $i1
}

while getopts :h option
do
	case "$option" in
    	h)
      		display_help
      		exit 1
      	;;
    	*)
      		echo "ERROR: Invalid parameters" >&2 
      		display_help
      		exit 1
      ;;
  esac
done

case "$1" in
	router)
		router_config
		exit 0
	   	;;
    client)
		client_config
    	exit 0
      	;;
    server)
		server_config
		exit 0
		;;
	*)
		echo -e "ERROR: machine indication needed:\n\trouter\n\tclient\n\tserver"
		exit 1
esac
