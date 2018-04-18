Some notes

Per saber el nivell en el que ens trobem:
	who -r
	sudo runlevel

Amb els DEAMONS:
	-sempre hem de declarar el PATH
	-un punt seguit d'un espai en blanc, farà que s'executi l'script en la mateixa shell (no crea un entorn nou)


pstree --> per saber tots els processos que s'han engegat
systemctl list-units –all --> mostra tot, serveis, montures, dispositius....
systemctl list-unit-files --> mostra tots els serveis i el seu estat actual

sudo journalctl --> mostra tots els serveis que es van executant
sudo journalctl --disk-usage --> permet saber quina quantitat de menmoria ocupen els journals actuals

systemctl comanda application.service
	on comanda potser:
		status | start | stop | restart | reload
		edit | edit --full
		enable | disable
		is-active | is-enabled | is-failed
		cat
		list-dependencies
		show
		mask | unmask
systemctl daemon-reload

per canviar el runlevel:
systemctl get-default
		halt -->para
		rescue
		poweroff
		reboot
systemctl set-default multi-user.target | graphical.target
systemctl list-dependencies multi-user.target

telint [valor numeric]

per iniciar el terminal ctrl + Alt + F1

tar:
	-és recursiu si no li indiquem lo contrari
	-T passem un fitxer on en el seu interior hi ha els fitxers que volem comprimir
	

find