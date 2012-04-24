#!/bin/sh

for m in `./ssid2mac.pl $1`
do echo "mac:    $m" > /dev/null
    for s in `./ssid2ser.pl -s $1 -c config.txt -m $m` 
    do echo "ser:    $s" > /dev/null
	./sermac2wpa.pl -q -s $s -m $m
    done
done
