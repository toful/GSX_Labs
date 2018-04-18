#!/bin/bash

#####################################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marin                              #
# Data d'implementació: 11/4/2018                                                   #
# Versio 1.0                                                                        #
# Permisos:        												                   	#
#####################################################################################

function display_help(){
	echo "help"
}

function install_all(){
	apt-get install nfs-common nfs-kernel-server
	apt-get install ypserv portmap
}

function set_NIS_NFS(){
	###NFS configuration
	mkdir /home/remots
	#modifing the /etc/export file
	ServerIP = $(hostname -I | cut -d ' ' -f1)
	network = $(hostname -I | cut -d ' ' -f1 | cut -d '.' -f1-3)
	#echo "/home/remots $network.0/255.255.255.0 (rw)" > /etc/export
	echo "/home/remots * (rw)" > /etc/export
	#creating the NFS table that holds the exports of your shares
	exportfs -a
	sudo /etc/init.d/nfs-kernel-server restart

	#https://docs.oracle.com/cd/E52668_01/E54669/html/ol7-s15-auth.html
	#-----------------------------------------------------------------------------------------------------------
	#NIS server configuration
	chmod o+w /home/remots
	useradd -m -d /home/remots/user1 -b /home/remots/user1 -p user1 -s /bin/bash user1
	useradd -m -d /home/remots/user2 -b /home/remots/user2 -p user2 -s /bin/bash user2
	useradd -m -d /home/remots/user3 -b /home/remots/user3 -p user3 -s /bin/bash user3

	#defining the NIS domain
	echo "NISDOMAIN=mynisdom" >> /etc/sysconfig/network

	#configure NIS options and add rules for which hosts and domains can access which NIS maps
	echo "$network.0/24: mynisdom : * : none" >> /etc/ypserv.conf
	echo "* : * : * : deny" >> /etc/ypserv.conf

	#Creating the file /var/yp/securenets and adding entries for the networks for which the server should respond to requests
	echo "255.255.255.255 127.0.0.1" > /var/yp/securenets
	echo "255.255.255.0   $network.0" >> /var/yp/securenets

	NISSERVER=true >> /etc/default/nis
	NISCLIENT=false >> /etc/default/nis

	#Editing the /var/yp/Makefile file
	#echo "all:
	#passwd group auto.home
	# hosts rpc services netid protocols mail
	# netgrp shadow publickey networks ethers bootparams printcap
	# amd.home auto.local. passwd.adjunct
	# timezone locale netmasks"
	#This example allows NIS to create maps for the /etc/passwd, /etc/group, and /etc/auto.home files.
	#By default, the information from the /etc/shadow file is merged with the passwd maps, and the information 
	#from the /etc/gshadow file is merged with the group maps.

	#Configure the NIS services:

	#Start the ypserv service and configure it to start after system reboots:
	systemctl enable ypserv
	systemctl start ypserv

	#Start the yppasswdd service and configure it to start after system reboots:
	systemctl enable yppasswdd
	systemctl start yppasswdd

	systemctl restart rpcbind
	systemctl restart nis

	/usr/lib/yp/ypinit -m
	#Update the NIS maps:
	make -C /var/yp
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
