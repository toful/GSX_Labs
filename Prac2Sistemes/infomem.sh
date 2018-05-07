#!/bin/bash

<<INSTRUCCIONS
Es vol fer un script que s'executi en el moment en que un usuari entra al sistema i
l'informi de l'espai de disc que s'està utilitzant sota del seu directori d'entrada. Volem
usar la comanda du per a calcular l'espai del disc que ocupa.
INSTRUCCIONS

###############################################################################
# Autors: Cristòfol Daudèn, Aleix Marine i Josep Marín Llaó                                           
# Data d'implementació: 2/5/2018                                                   5
# Versio 1.0                                                                        
# Permisos: Per a que la comanda du pugui comptabilitzar tots els fitxers ha de poder 
# accedir a tots els subdirectoris que pengen de $HOME.                                  
# Descripció i paràmetres: Es vol implementar un script que s'executi en el moment en que un
# usuari entra al sistema i l'informi de l'espai de disc que s'està utilitzant sota del seu   
# directori d'entrada. Volem usar la comanda du per a calcular l'espai del disc que ocupa.
#
# Arguments: Sense arguments. Tampoc necessita ajuda ja que no esta pensat per 
# a ser executat a través d'un tty. 
###############################################################################


xmessage -buttons Ok:0 -default Ok -nearmouse "Hello $USER, your home folder weights $(du -s $HOME | cut -d$'\t' -f1) Bytes ($(du -sh $HOME | cut -d$'\t' -f1))" -timeout 30

