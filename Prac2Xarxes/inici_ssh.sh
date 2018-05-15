#!/bin/bash
function display_help(){
	echo -e "This script configurates ssh service in a indicated machine. All machines
will install and configure openssh-server. 
	Argument one: [server|router|client]
	"
}

function router_config()
{
	echo .
}

function client_config()
{
	apt-get install openssh-client
}

function server_config()
{
	echo .	
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
		router_config
		exit 0
	   	;;
	server)
		server_config
		exit 0
		;;
	client)
		client_config
		exit 0
		;;
	*)
		echo -e "ERROR: machine indication needed:\n\trouter\n\tserver\n\tclient"
		exit 1
esac

