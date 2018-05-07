Some notes

fdisk -l
	serveix per llistar tots els discs que hi ha connectats

dd if=if/dev/zero of=/swap bs=1024 count=1024
	copia un fitxer formatant-lo dacord amb els opernats
	if -> (imput file)
	of -> (output file)
	bs -> (block size) defineix la mida de bloc
	count -> indica el nombre de blocs a agafar del sistema de fitxers

mkswap /swap
	formatejar el fitxer/disc/partició com a fitxer de swap

swapoff /dev/sda6
	el swap deixar de usar aquest fitxer com a àrea de swap

swapon /swap
	s'usarà el fitxer indicat coma àrea de swap

swapon -s
	serveix per llistar totes les particions de swap

mkfs -t ext2 /dev/sda6
	serveix per formatejar el fitxer/disc/partició amb el format indicat
	enlloc de ext2 també pot ser vfat
	si no podem provar en:
		mkfs.ext2 -F /dev/sda6

mount /dev/sda6 -t vfat /mnt
	serveix per muntar el sistema de fitxers en un direcotri

df
	mostra on estan muntats tots els sistemes de fitxers

dumpe2fs /dev/sda5
	et mostra tota la informació d'un disc

tune2fs /dev/sda5
	el permet canviar tot el sistema de fitxers d'un determinat disc

debugfs /dev/sda5
	et permet fer el que les dues comandes anteriors, a més de moltes més funcionalitats (help)
	podries ser capaç de recuperar el inode d'un fitxer esborrat

/etc/fstab
	tota la informació de les particions o discs que s'han de muntar al iniciar el sistema
	s'ha de modificar si es volen fer els canvis anteriors permanents



#FASE DISPOSITIUS
ls -l /dev --> PERMISOS SOFTLINKS USER GROUP MAJOR MINOR
	major --> index manegador del dispositiu
	minor --> com accedir al dispositiu concret

df
	permet veure tots els dispositius muntats

si volem que sempre que s'inicie la màquina es monti una aprtició ho hem d'especificar en el --> /etc/fstab

CUPS

Encriptar
crypt
$TIPUS_ENCRIPTACIÓ$SALT$PASS_ENCRYPT

stty -a
	per veure totes les característiques dels terminals que s'estan executant en un determinat moment

mknod <nomPipe> p
	per crear una pipe


#ACCOUNTING I MONITORITZACIÓ
ulimit -a --> ens mostra els límits de la bash, per veure la comanda: man bash
	per modificar-ho en tots els usuaris, modificar el .bashrc

/etc/security/limits.conf --> En aquest feitxer e spoden definir diferents dominis (usuaris, grups, ..) i limitar el numero de processos per a aquests dominis definits (dona més personalització que la opció anterior)
	s'ha de reinciciar el sistema per a que es fagin efectius aquests canvis
	si no volem reiniciar la màquina: /etc/pam.d/common-session i afegim la següent linia al final: "session optional pam_limits.so" i fem un sudo pam-auth-udate --force

