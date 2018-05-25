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
	
	#Politiques per defecte restrictives
	iptables -P INPUT DROP
	iptables -P OUTPUT DROP
	iptables -P FORWARD DROP
	
	#Permetre loopback
	iptables -A INPUT -i lo -j ACCEPT
	iptables -A OUTPUT -o lo -j ACCEPT
	
	
	#Permetre conexions consulta DNS
	iptables -A FORWARD -i eth0 -o eth1 -p UDP -d 192.168.17.2 --destination-port 53 -j ACCEPT
	
	#Permetre pings
	iptables -A FORWARD -i eth1 -o eth0 -p icmp -s 192.168.17.2 -j ACCEPT
	
	#Permetre conexions SSH 
	iptables -A FORWARD -i eth1 -o eth0 -p TCP -s 192.168.17.2 --dport 22 -j ACCEPT
	
	#Permetre resposta a les conexions establertes, mitjançant configuració statefull
	iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT	
	
  
    /etc/init.d/bind9 restart

}

function intranet_firewall(){
	#Eliminem regles anteriors
	iptables -F
	iptables -X
	
	#Politiques per defecte permetent conexions sortints desde l'intranet
	iptables -P INPUT DROP
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD DROP
	
	#Permetem les respostes, mitjançant configuració statefull
	iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

    /etc/init.d/bind9 restart

}

function dmz_firewall(){
	#Eliminem regles anteriors
	iptables -F
	iptables -X
	
	#Politiques per defecte permetent conexions entrants
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT DROP
	iptables -P FORWARD DROP
	
	#Permetem les respostes, mitjançant configuració statefull
	iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    
	/etc/init.d/bind9 restart
	
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
