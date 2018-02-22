#!/bin/bash

#####################################################################################
# Autors: Cristòfol Daudèn, Aleix Mariné i Josep Marin Llaó 											#
# Data d'implementació: 7/2/2018													#
# Versió 1.0																		#
# Descripció i paràmetres: Aquest script configura una nova interfície de xarxa,    #
# afegint al fitxer /etc/network/interfaces la informació necessaria. Aquesta info  #
# serà aportada pels paràmetres de la següent manera:								#
									#
#####################################################################################

(crontab -l 2>/dev/null; echo "21 11 21 02 * $PWD/sd.sh") | crontab -

