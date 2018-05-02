#!/bin/bash

if [ -a log.txt ]; then
	rm log.txt
fi

echo "		RESULTATS" > log.txt
echo "......................................." >> log.txt
make all

echo "CPU TEST" >> log.txt
timeout 6 ./cpu &
vmstat -a 1 5 | tail -n +3 | awk {'print $13'} | tac >> log.txt

echo "RAM TEST" >> log.txt
timeout 6 ./ram &
vmstat -a 1 5 | tail -n +3 | awk {'print $4'} | tac >> log.txt

echo "DISK TEST" >> log.txt
timeout 6 ./disk test 5120 &
vmstat -d 1 5 | tail -n +3 | awk {'print "Reads: "$2"\t"  "Writes: "$6'} | tac >> log.txt


echo "Finished"


