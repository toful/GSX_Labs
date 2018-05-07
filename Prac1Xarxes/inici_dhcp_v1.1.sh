#!/bin/bash
function display_help(){
	echo -e "This script is for setting up the GSX subjct network configuration\
It has been done for a three machine structure, a router (with three interfaces),a server and client (with only one interface).
You have to indicate wich machine do you want to configure in the first argument:
\trouter\n\tclient\n\tserver
	"
}

function router_config(){
	
}	

function server_config(){
	
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
    server)
		server_config
		exit 0
		;;
	*)
		echo -e "ERROR: machine indication needed:\n\trouter\n\tclient\n\tserver"
		exit 1
esac
