#!/usr/bin/perl 
#
# ------------------------------------------------------------------------
# Copyright (C) 2010 Valerio Di Giampietro (email: v@ler.io)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software Foundation,
# Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
# ------------------------------------------------------------------------
#
# spiegazione algoritmo  su: http://www.gibit.net/forum/viewtopic.php?f=10&t=11
#
$debug=0;
$ssid=uc $ARGV[0];
$ssid=~s/^Alice-//i;
print "ssid (num):   $ssid \n" if ($debug);
die "Errore nel SSID: $ARGV[0]\n" unless ($ssid=~/^\d{8}$/);
# inserito anche 00268d di celltel che si trova su qualche router
# della serie Alice-181.....
@macpirelli=qw/
    6487D7
    38229D
    00A02F
    002553
    00238E
    002233
    001D8B
    001CA2
    00193E
    0017C2
    0013C8
    000827
    00268D/;

$lastmacdigits[0]=sprintf("%0X",$ssid);
$lastmacdigits[1]=sprintf("%0X","1" . $ssid);
$lastmacdigits[2]=sprintf("%0X","2" . $ssid);
for $i (0 .. 2) {
    print "last mac digits [$i]: $lastmacdigits[$i]\n" if ($debug);
}
for $i (@macpirelli) {
    #print $i,"\n";
    for $j (@lastmacdigits) {
	if (substr($i,5,1) eq substr($j,0,1)) {
	    push @macs,$i . substr($j,1,6);
	}
    }
}

for $i (@macs) {
    print "$i\n";
}


