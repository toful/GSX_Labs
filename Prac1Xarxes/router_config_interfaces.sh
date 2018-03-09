#!/bin/bash
#
#Fitxer de configuració del ROUTER

if [ $# -lt 4 ]
then
	echo "Usem la configuració per defecte"
	echo "ERROR, you have to indroduce four argumnets" >&2

	#Llistem les interfícies de xarxa
	interfaces=$(ip addres show | egrep -e "^[0-9]" | cut -d ':' -f2 | tr -d ' ' | sed '/lo/d')
	i1=$(echo $interfaces | cut -d ' ' -f1)
	i2=$(echo $interfaces | cut -d ' ' -f2)
	i3=$(echo $interfaces | cut -d ' ' -f3)
	addres=10.21.10.4

else
	i1=$1
	i2=$2
	i3=$3
	addres=$4
fi

#revisar la configuració de l'adreça
config="auto lo\niface lo inet loopback
	\n
	\nauto $i1\niface $i1 inet static\n\taddress $addres\n\tnetmask 255.255.0.0\n\tnetwork 10.21.0.0\n\tgateway 10.21.1.1
	\n
	\nallow-hotplug $i2\niface $i2 inet static\n\taddress 192.168.16.1\n\tnetmask 255.255.255.0\n\tnetwork 192.168.16.0\n\tbroadcast 192.168.16.255
	\n
	\nallow-hotplug $i3\niface $i3 inet static\n\taddress 192.168.17.1\n\tnetmask 255.255.255.0\n\tnetwork 192.168.17.0\n\tbroadcast 192.168.17.255"

#escribim canvis en el fitxer /etc/network/interfaces
echo -e $config > /etc/network/interfaces

#Afegim les rutes que calguin
#echo "up ip route add ip1/mask via ip2/mask dev <inteface> >> /etc/network/interfaces"

#Activem el forwarding
echo 1 >/proc/sys/net/ipv4/ip_forward

#permetem el forwardind de paquets a través del router
iptables -A FORWARD -i $i2 -j ACCEPT
iptables -A FORWARD -o $i2 -j ACCEPT
iptables -A FORWARD -i $i3 -j ACCEPT
iptables -A FORWARD -o $i3 -j ACCEPT

#permetem el tràfic cap a l'exterior
iptables -I INPUT -j ACCEPT
iptables -t nat -A POSTROUTING -s 172.168.16.0/24 -j SNAT --to $addres
iptables -t nat -A POSTROUTING -s 192.168.17.0/24 -j SNAT --to $addres

#ip route add default via <ip router extern>? No fa falta no? en teoria el router ja té conexió

#reiniciem els servis de xarxa
/etc/init.d/networking restart

