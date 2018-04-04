#!/bin/bash
function display_help(){
	echo -e "This script configurates a VLAN between two computers. The one
with a unique interface will be the sever, and the one with three interfaces will be the 
router. You can choose between this two configuration using the first argument when running
this script.
	Argument one: [server|router]
	Argument two (optional): name of the interface where the VLAN will be created
	Argument three (optional): IP of the configured machine on the VLAN
	
	"
}

function router_config(){
	if [ $# -lt 3 ]
	then
		echo "Usem la configuració per defecte"

		#Obtenim la segona interficie que sera la que 
		i2=$(ip addres show | egrep -e "^[0-9]" | cut -f2 -d ':' | tr -d '\n' | cut -f4 -d ' ')
		IP="192.168.250.1"
	
	else
		i2=$2
		IP=$3
	fi
	
	net=$(echo $IP | cut -f1,2 -d '.')

echo -e "ip link add link $i2 name $i2.102 type vlan id 7
	ip addr add $IP/23 brd $net.1.255 dev $i2.102
	ip link set $i2.102 up"
	ip link add link $i2 name $i2.102 type vlan id 7
	ip addr add $IP/23 brd $net.1.255 dev $i2.102
	ip link set $i2.102 up

}



function server_config(){
	if [ $# -lt 3 ]
	then
		echo "Usem la configuració per defecte"

		#Obtenim la interficie 
		i1=$(ip address show | grep -e "^[0-9]" | cut -d ':' -f2 | tr '\n' ' ' | cut -d ' ' -f4)
		IP="192.168.250.2"
	else
		i1=$2
		IP=$3
	fi
	
	net=$(echo $IP | cut -f1,2 -d '.')
echo -e "ip link add link $i1 name $i1.102 type vlan id 7
	ip addr add $IP/23 brd $net.1.255 dev $i1.102
	ip link set $i1.102 up"

	ip link add link $i1 name $i1.102 type vlan id 7
	ip addr add $IP/23 brd $net.1.255 dev $i1.102
	ip link set $i1.102 up
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

# ensure that VLAN package is installed
apt-get install vlan
# charge 8021q module into kernel
modprobe 8021q

case "$1" in
	router)
		router_config
	   	;;
    server)
		server_config
		exit 0
		;;
	*)
		echo -e "ERROR: machine indication needed:\n\trouter\n\tserver"
		exit 1
esac

