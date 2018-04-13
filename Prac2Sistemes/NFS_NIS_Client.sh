#!/bin/bash

#####################################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marin                              #
# Data d'implementació: 14/4/2018                                                   #
# Versio 1.0                                                                        #
# Permisos:        												                   	#
# -Argument 1: NFS IP address 														#
#####################################################################################

function display_help(){
	echo "help"
}

function install_all(){
	apt-get install portmap nfs-common
	apt-get install nis
	apt-get install install yp-tools ypbind
	apt-get install autofs
}

function set_NIS_NFS(){
	#/etc/init.d/portmap restart

	mkdir /home/remot/nfs_local
	mount -t nfs $1:/home/remots /home/remot

	#Modifing the /etc/yp.conf file
	echo "ypserver $1" > /etc/yp.conf

	#Modifing the /etc/nsswitch.conf file
	echo "passwd: compat nis" > /etc/nsswitch.conf
	echo "shadow: compat nis" >> /etc/nsswitch.conf
	echo "group: compat nis" >> /etc/nsswitch.conf
	echo "netgroup: nis" >> /etc/nsswitch.conf
	echo "hosts: files dns nis" >> /etc/nsswitch.conf

	echo "+::::::" >> /etc/passwd
	echo "+:::" >> /etc/group
	echo "+::::::::" >> /etc/shadow

	systemctl restart ypbind

	# Montatge automàtic al iniciar el PC
	#Afegir en /etc/fstab
	#echo "$1:/home/remots/$user /home/remot nfs" >> /etc/fstab

	#Per desmuntar:
	#sudo umount /home/remot

	#Configuring an NIS Client to Use Automount Maps-------------------------------------------

	#	apt-get install install yp-tools ypbind
	#	apt-get install autofs

	#	system-config-authentication

	#Create an /etc/auto.master file that contains the following entry:
	#	/home/remot /etc/auto.home

	#Verify that the auto.home map is available:
	#	ypcat -k auto.home
	#	*    -rw,sync    nfssvr:/home/remot/&

	#In this example, the map is available. For details of how to make this map available, see Section 24.5.3, “Adding User Accounts to NIS”.
	#If the auto.home map is available, edit the file /etc/auto.home to contain the following entry:
	#	+auto.home

	#This entry causes the automounter to use the auto.home map.
	#Restart the autofs service, and configure the service to start following a system reboot:
	#	systemctl restart autofs
	#	systemctl enable autofs
}

while getopts :h option
do
    case "$option" in
        h)
            display_help
            exit 0
        ;;
        i)
			echo "Installing all the packets"
            install_all
            exit 0
        ;;
        *)
            echo "ERROR: Invalid parameters" >&2 
            display_help
            exit 1
      	;;
  esac
done

set_NIS_NFS
exit 0
