#!/bin/bash
function display_help(){
    echo -e "This script is for setting up the GSX subjct network configuration.
It has been done for a three machine structure, a router (with three interfaces),a server and client (with only one interface).
In this script a DNS service is also implemented.
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

    #revisar la configuració de l'adreça
    config="auto lo\niface lo inet loopback
        \n
        \nauto $i1\niface $i1 inet dhcp
        \n
        \nallow-hotplug $i2\niface $i2 inet static\n\taddress 172.17.2.1\n\tnetmask 255.255.255.0\n\tnetwork 172.17.2.0\n\tbroadcast 172.17.2.255
        \n
        \nallow-hotplug $i3\niface $i3 inet static\n\taddress 192.168.8.1\n\tnetmask 255.255.254.0\n\tnetwork 192.168.8.0\n\tbroadcast 192.168.9.255"

    cp -p dhcpd.conf /etc/dhcp/dhcpd.conf

    sed -i "s/INTERFACES=\".*\"/INTERFACES=\"$i2 $i3\"/g" "/etc/default/isc-dhcp-server"
    #Apaguem les interfícies de xarxa
    ifdown $i1 --force
    ifdown $i2 --force
    ifdown $i3 --force

    #escribim canvis en el fitxer /etc/network/interfaces
    echo -e $config > /etc/network/interfaces

    #Activem el forwarding
    echo 1 >/proc/sys/net/ipv4/ip_forward

    echo -e "options{\n\tdirectory \"/var/cache/bind\";\n\tforwarders {" > /etc/bind/named.conf.options
    IFS=$'\n'
    for line in $(cat /etc/resolv.conf)
    do
        if [ "$(echo $line | egrep -e "[0-9].*")" != "" ]
        then        
            echo -e "\t\t$(echo $line | egrep -e "[0-9].*" | cut -d ' ' -f2);" >> /etc/bind/named.conf.options
        fi  
    done
    echo -e "\t};\n};" >> /etc/bind/named.conf.options

    cp named.conf.local /etc/bind/named.conf.local
    cp DMZ_2.gsx.db /var/cache/bind/DMZ_2.gsx.db
    cp INTRANET.db /var/cache/bind/INTRANET.db
    cp db.192.168.9 /var/cache/bind/db.192.168.9
    cp db.192.168.8 /var/cache/bind/db.192.168.8
    cp db.172 /var/cache/bind/db.172

    cp db.192.168.250 /var/cache/bind/db.192.168.250
    cp VLAN.db /var/cache/bind/VLAN.db

    #reiniciem les interficies de xarxa
    ifup $i1
    ifup $i2
    ifup $i3

    #obtenim la ip amb conexio a internet del router
    addres=$(hostname -I | cut -d ' ' -f1) 

    #permetem el tràfic cap a l'exterior
    iptables -I INPUT -j ACCEPT
    iptables -t nat -A POSTROUTING -s 192.168.8.0/23 -j SNAT --to $addres
    iptables -t nat -A POSTROUTING -s 172.17.2.0/24 -j SNAT --to $addres

    sed -e '1i nameserver 127.0.0.1' /etc/resolv.conf > resolv.conf
    cp resolv.conf /etc/resolv.conf
    rm resolv.conf

    /etc/init.d/bind9 restart

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
        \nallow-hotplug $i1\niface $i1 inet dhcp"

    ifdown $i1 --force

    #escribim canvis en el fitxer /etc/network/interfaces
    echo -e $config > /etc/network/interfaces

    echo -e "domain INTRANET\nsearch INTRANET\nnameserver 192.168.8.1" > /etc/resolv.conf

    Afegim les rutes que calguin
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

    #revisar la configuració de l'adreça
    config="auto lo\niface lo inet loopback
        \n
        \nallow-hotplug $i1\niface $i1 inet dhcp"

    ifdown $i1 --force

    #escribim canvis en el fitxer /etc/network/interfaces
    echo -e $config > /etc/network/interfaces

    echo -e "domain DMZ_2.gsx\nsearch DMZ_2.gsx\nnameserver 172.17.2.1" > /etc/resolv.conf

    Afegim les rutes que calguin
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
