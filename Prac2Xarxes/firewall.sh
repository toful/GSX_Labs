#!/bin/bash
function display_help(){
    echo -e "This script is for setting up the GSX firewall  configuration.
You have to indicate wich machine do you want to configure in the first argument:
\trouter\n\tclient\n\tserver
    "
}

function router_firewall(){
	#Eliminem regles anteriors
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X

    iptables -P INPUT DROP
    iptables -P OUTPUT ACCEPT
    iptables -P FORWARD DROP

    iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT

    iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
    iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
    iptables -A INPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT

    #Es permet la comunicació de la màquina amb si mateixa.
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT

    #Implementa SNAT quan la connexió prové d'una màquina de la xarxa interna.
    iptables -t nat -A POSTROUTING -s 192.168.8.0/23 -j SNAT --to $addres
    iptables -t nat -A POSTROUTING -s 172.17.2.0/24 -j SNAT --to $addres
    iptables -t nat -A PREROUTING -i $i1 -p tcp --dport 80 -j DNAT --to-destination 172.17.2.2:80
    iptables -t nat -A PREROUTING -i $i1 -p tcp --dport 443 -j DNAT --to-destination 172.17.2.2:443
    iptables -t nat -A PREROUTING -i $i1 -p tcp --dport 23 -j DNAT --to-destination 172.17.2.2:22

    #Permet el pas de les consultes DNS si van dirigides a un DNS 
    iptables -A FORWARD -p udp  --dport 53 -j ACCEPT

    #Permet el pas de les comunicacions HTTP i HTTPS dirigides al Server de la DMZ.
    iptables -A FORWARD -p tcp --dport 80 -j ACCEPT
    iptables -A FORWARD -p tcp --dport 443 -j ACCEPT

    #Permet sortir les comunicacions TCP que provenen d'una màquina de la xarxa interna o de la DMZ.
    iptables -A FORWARD -p tcp -s 192.168.8.0/23 -j ACCEPT
    iptables -A FORWARD -p tcp -s 172.17.2.0/24 -j ACCEPT

}

function intranet_firewall(){
	#Eliminem regles anteriors
	iptables -F
    iptables -X

    iptables -P INPUT DROP
    iptables -P OUTPUT ACCEPT
    iptables -P FORWARD DROP

    iptables -A INPUT -i lo -j ACCEPT
        
    iptables -A INPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -p icmp -m state --state ESTABLISHED,RELATED -j ACCEPT

    #Accepta peticions de connexions SSH i/o SFTP.
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT

    #Accepta i respon els "ping" des de qualsevol màquina de la xarxa interna i/o la DMZ.
    iptables -A INPUT -p icmp --icmp-type 8 -s 192.168.8.0/24 -j ACCEPT
    iptables -A INPUT -p icmp --icmp-type 8 -s 172.17.2.0/24 -j ACCEPT

}

function dmz_firewall(){
	#Eliminem regles anteriors
	iptables -F
    iptables -X

    iptables -P INPUT DROP
    iptables -P OUTPUT DROP
    iptables -P FORWARD DROP

    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT

    #Permetem la resposta a peticions entrants
    iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

    #Accepta connexions SSH.
    iptables -A INPUT -p tcp --dport 22 -j ACCEPT

    #Accepta connexions HTTP i HTTPS.
    iptables -A INPUT -p tcp --dport 80 -j ACCEPT
    iptables -A INPUT -p tcp --dport 443 -j ACCEPT

    #pot fer consultes DNS
    iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
    iptables -A INPUT -p udp -m state --state ESTABLISHED,RELATED -j ACCEPT

    iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT

    iptables -A INPUT -p tcp -m state --state ESTABLISHED,RELATED -j ACCEPT

    #Accepta i respon els "ping".
    iptables -A INPUT -p icmp --icmp-type 8 -j ACCEPT
    iptables -A OUTPUT -p icmp --icmp-type 8 -j ACCEPT
	

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
        router_firewall
        exit 0
        ;;
    client)
        intranet_firewall
        exit 0
        ;;
    server)
        dmz_firewall
        exit 0
        ;;
    *)
        echo -e "ERROR: machine indication needed:\n\trouter\n\tclient\n\tserver"
        exit 1
esac
