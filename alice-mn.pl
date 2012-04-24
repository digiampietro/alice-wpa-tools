#!/usr/bin/perl 
# Calcolo dei magic number dato SSID, Serial e Mac
# il Mac serve per scrivere la riga da inserire nel config.txt
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

#
use Getopt::Std;

sub usage {
    print "$0 -s SSID -n serial -m mac [-f] [-d]\n";
    print "   -d print debugging information\n";
    print "   -f full  print values for k=8 and k=13, default is: \n";
    print "            serial ending in 3 and 4  k=8 otherwise k=13\n";
    exit;
}

getopts('s:n:m:df');

usage() unless ($opt_s and $opt_n and $opt_m);

$ssid=$opt_s;
$ssid=~s/Alice-//i;
$mac=$opt_m;
$mac=~s/[\ \-\:]//g;
($sn1,$sn)=split (/X/,$opt_n);
$serie=substr($ssid,0,3);
die "Errore nel mac address $mac \n" unless ($mac=~/^[0-9a-f]{12}$/i);
die "Errore nel seriale $opt_s\n"    unless (($sn1=~/^\d{5}$/) and ($sn=~/^\d{7}$/));
die "Errore nell'SSID\n"             unless ($ssid=~ /^\d{8}$/);

print "serie: $serie, ssid: $ssid, sn1: $sn1, sn: $sn, mac: $mac\n" if $opt_d;
for $k (8,13) {
    if  (
          (($k == 8) and ($sn1 =~ /6...(3|4)/)) or
          (($k != 8) and ($sn1 !~ /6...(3|4)/)) or
          $opt_f
	) 
    {
	$q=$ssid - $k*$sn;
	print "Q: $q, k: $k\n" if $opt_d;
	print '"' . "$serie,$sn1,$k,$q," . substr($mac,0,6) . '";' . "\n";
    }
}
