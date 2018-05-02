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
# Permisos: permisos per a crear un fitxer a $HOME                                   
# Descripció i paràmetres: Es vol implementar un script que s'executi en el moment en que un
# usuari entra al sistema i l'informi de l'espai de disc que s'està utilitzant sota del seu   
# directori d'entrada. Volem usar la comanda du per a calcular l'espai del disc que ocupa.
#
# Aquest script no necessita arguments, excepte el d'ajuda que es opcional.
# 
# Aquest script instal·la una sola línia de codi al fitxer ~/.profile que 
# mostra una notificació d'escriptori quan l'usuari es logueja.
###############################################################################
echo $(whoami) >> /home/amt/funsiono
> /home/amt/funsiono
notify-send "Avís memoria" "Hola $USER, la teva carpeta d'inici ocupa $(du -s $HOME | cut -d$'\t' -f1) Bytes ($(du -hs $HOME | cut -d$'\t' -f1))" 2> /dev/nul

