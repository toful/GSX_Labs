#!/bin/bash

#####################################################################################
# Autors: Cristòfol Daudèn, Aleix Mariné i Josep Marin                              #
# Data d'implementació: 23/2/2018													#
# Versió 1.0																		#
# Permisos i requeriments: Aquest script no necessita privilegis d'usuari, pero uti-#
# litza la comanda lastcomm que pot no estar disponible en tots els SO.             # 
# Aquesta comanda pot instal·lar-se utilitzant la comanda "sudo apt install acct".  #
#																					#
# Descripció i paràmetres: Aquest script mostra UN SOL COP el nom de totes les 		#
# comandes ordenades alfabéticament que s'han engegat entre les 13:00 i les 14:59 i #
# que han dut a terme la crida al sistema fork sense haver dut a terme un exec a 	#
# posteriori, així com l'usuari que ha executat aquestes comandes. Es pot 			#
# especificar l'argument "-r" per a mostrar en quin moment exacte s'ha executat la  #
# comanda, així com les diferents possibles execucions de la mateixa comanda en 	#
# aquest periode de temps.    														#
# - Argument 1: -[h|r]	 															#
#####################################################################################

function ayuda {
	echo "
###############################################################################
# Autors: Cristòfol Daudèn, Aleix Mariné i Josep Marin                        #
# Data d'implementació: 23/2/2018                                             #
# Versió 1.0                                                                  #
# Permisos i requeriments: Aquest script no necessita privilegis d'usuari,    #
# pero utilitza la comanda lastcomm que pot no estar disponible en tots els   #
# SO.                                                                         # 
# Aquesta comanda pot instal·lar-se utilitzant la comanda                     #
# sudo apt install acct                                                       #
#                                                                             #
# Descripció i paràmetres:Aquest script mostra UN SOL COP el nom de totes les #
# comandes ordenades alfabéticament que s'han engegat entre les 13:00 i les   #
# 14:59 i                                                                     #
# que han dut a terme la crida al sistema fork sense haver dut a terme un exec#
# a posteriori, així com l'usuari que ha executat aquestes comandes. Es pot   #
# especificar l'argument -r per a mostrar en quin moment exacte s'ha          #
# executat la comanda, així com les diferents possibles execucions de la      #
# mateixa comanda en aquest periode de temps.                                 #
# - Argument 1: -[h|r]                                                        #
###############################################################################
"
}

if [ $# -le 1 ]; then
	if [ "$1" = "-h" ]; then
		ayuda
		exit 0
	elif [ "$1" = "-r" ]; then
		lastcomm | grep -E "^.* .F... .* 1[3,4]:..$" | cut -c1-17,24-32,65-69 | sort
		exit 0
	elif [ "$1" = "" ]; then
		lastcomm | grep -E "^.* .F... .* 1[3,4]:..$" | cut -c1-17,24-32 | sort | uniq
		exit 0
	else 
		echo -E "L'argument $1 no és reconeix. Mostrant l'ajuda..."
		ayuda
		exit 1
	fi
else
	echo "Hi ha massa arguments. Mostrant l'ajuda..."
	ayuda
	exit 1
fi
