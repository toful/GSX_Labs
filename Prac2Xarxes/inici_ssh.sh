#!/bin/bash
function display_help(){
	echo -e "This script configurates ssh service in a indicated machine. All machines
will install and configure openssh-server. 
	Argument one: [server|router|client]
	"
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

apt-get update # actualitzem repositoris sino de vegades dona error
apt-get install openssh-server

case "$1" in
	router)
		exit 0
	   	;;
	server)
		exit 0
		;;
	client)
        apt-get install openssh-client
		exit 0
		;;
	*)
		echo -e "ERROR: machine indication needed:\n\trouter\n\tserver\n\tclient"
		exit 1
esac

