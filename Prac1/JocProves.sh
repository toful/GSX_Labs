#!/bin/bash

#####################################################################################
# Autors: Cristòfol Daudèn i Aleix Mariné											#
# Data d'implementació: 8/2/2018													#
# Versió 1.0																		#
# Descripció i paràmetres: Joc de proves pels scripts gpgp.sh i rpgp.sh				#				#
# - Argument 1: NoN																	#
#####################################################################################

#running gpgp.sh with no arguments:
echo Correm el script gpgp.sh sense arguments
./gpgp.sh 2> std.err
cat std.err

#creating many files to check the scripts
mkdir JocProves
echo a>JocProves/a.txt
echo b>JocProves/b.txt
echo c>JocProves/c.txt
echo d>JocProves/d.txt
mkdir JocProves/prova

#saving the files path in a new file
echo JocProves/a.txt > JocProves/paths.txt
echo JocProves/b.txt >> JocProves/paths.txt
echo JocProves/c.txt >> JocProves/paths.txt
echo JocProves/d.txt >> JocProves/paths.txt
echo JocProves/prova >> JocProves/paths.txt

echo
echo Correm el script gpgp.sh:
#running gpgp.sh
./gpgp.sh JocProves/paths.txt > std.out 2> std.err
cat std.out

echo
echo Correm el script rpgp.sh sense arguments:
#running rpgp.sh with no arguments:
./rpgp.sh 2> std.err
cat std.err

echo
echo Correm el script rpgp.sh amb la sortida de gpgp.sh sense haver modificat cap fitxer:
#running rpgp.sh
./rpgp.sh std.out 2> std.err
cat std.err

#changing the access rights in a.txt file and removing the d.txt file
chmod u+x JocProves/a.txt
rm JocProves/d.txt
chown toful JocProves/b.txt

echo
echo Correm el script rpgp.sh amb la sortida de gpgp.sh havent modificat el fitxer a.txt i b.txt i borrat el d.txt:
#running rpgp.sh
./rpgp.sh std.out 2> std.err
#cat std.err

#removing all test files
rm -R JocProves