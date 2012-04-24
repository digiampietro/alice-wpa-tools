#!/usr/bin/perl 
#
# Dato l'SSID di Alice ritorna i probabili seriali, oppure niente se il seriale
# non viene trovato
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
$debug=0;
sub usage {
    print "usage: ssid2ser.pl -s ssid -c config.txt [-d] [-m mac] \n";
    print "  -d       print debugging information\n";
    print "  -m       mac address, opzionale, se presente restituisce il seriale\n";
    print "           solo se il mac fornito e' compatibile con quello del config.txt\n";
    print "  -n       utilizza la stringa fornita come fosse l'unica riga presente\n";
    print "           nel file config.txt\n";
    print "  -v       verbose, stampa un po' di informazioni\n";
    print "  -e       extended, usa anche i magic numbers delle serie precedenti e successive\n";
    print "  esempio: ./ssid2ser.pl -s Alice-54887113  -c config.txt\n";
    exit;
}

# getserial
#    restituisce il seriale a partire dai valori di ingresso
# IN: ssid         SSID rete alice
#     sn1          prima parte del seriale (prima della X)
#     k            magic number k
#     q            magin number q
sub getserial {
    my ($ssid,$sn1,$k,$q)=@_;
    my $sn2=($ssid-$q)/$k;
    my ($sn);
    print "getserial: ssid: $ssid, sn1: $sn1, k: $k, q: $q\n" if $debug;
    print "getserial: $sn2 " . int($sn2) . "\n" if $debug;
    if ((int($sn2) == $sn2) and ($sn2 >= 0)) {
	$sn=$sn1 ."X".sprintf('%07u',$sn2);
	if ($verbose and (! $serials{$sn})) {
	    print "serial: $sn (k: $k, q: $q) \n";
	}
    } else {
	$sn="";
    }
    return $sn;
}

# getvalues
#   per un dato SSID trova la riga, o le righe, corrispondenti e mette i relativi valori
#   nei vettori sn1 (prima parte del seriale)
#               k      costante magic
#               q      costange magica
#               mac1   primi 3 caratteri del mac
#   
sub getvalues {
    my $s=$_[0];
    my $found=0;
    print "getvalues :$s\n" if $debug;

    for $k (sort keys %cfg) {
	#print @{$cfg{$k}}, "\n";
	@l=@{$cfg{$k}};
	
	$l[0]=~s/X//g if ($l[0]);
	#print $l[0]," ",$s,"\n";
	if (($s =~ /^$l[0]/) and ($l[0])) {
	    #print "\nmatched\n";
	    #print $l[0],"\n";
	    $found++;
	    push @sn1,($l[1]);
	    push @k,($l[2]);
	    push @q,($l[3]);
	    push @mac1,($l[4]);
	    if ($verbose) {
		my $tmp=$";
		$"=",";
		print "using: @{$cfg{$k}} \n";
		$"=$tmp;
	    }
	}
	undef @l;
    }
    print "getvalues found: $found\n" if $debug;
    return $found;
}


getopts('s:c:dm:n:ve');

$verbose=$opt_v;
$debug=$opt_d;
$s = $opt_s or usage;
$s=~s/^Alice-//i;
die "Errore nell'SSID\n" unless ($s=~ /^\d{8}$/);
$cfg = $opt_c or $opt_n or usage;
if ($opt_m) {
    $mac=$opt_m;
    $mac=~s/://g;
    $mac=~s/-//g;
    $mac=lc $mac;
    die "Errore nel mac address $mac \n" unless ($mac=~/^[0-9a-f]{12}$/);
    $mac1=substr($mac,0,6);
}


# costriusce cfg, un hash of array che contine le righe del file
# di configurazione: la chiave dell'hash e' del tipo:
#     181-005
#     181-006
# per permetere di avere piu' righe di parametri corrispondenti
# alle prime 3 cifre dell'SSSID
# il contenuto e' un vettore contente le informazioni di config.txt
$c=0;
if ($opt_c) {
    open (F, $cfg) or die "Error opening $cfg\n";
    while (<F>) {
	next unless ($_);
	chomp;
	s/\;.*//;
	s/\"//g;
	#print $_,"\n";
	@l=split /\,/;             #/
	next unless ($l[0]);
	$c++;
	$cs=$l[0] . "-" . sprintf "%03u",$c;
	@{$cfg{$cs}}=@l;
    }
} else {
    $_=$opt_n;
    chomp;
    s/\;.*//;
    s/\"//g;
    @l=split /\,/;             #/
    next unless ($l[0]);
    $c++;
    $cs=$l[0] . "-" . sprintf "%03u",$c;
    @{$cfg{$cs}}=@l;
}

# fa costriuire da getvalues i vettori  @sn1, @q, @k, @mac1
# se la riga corrispondente ai primi 3 numeri dell'SSID di Alice non
# viene trovata incrementa e decrementa in modo da utilizzare le
# due serie adiacenti a quella non trovata
# (ad esempio non troviamo la serie "940" allora vengono utilizzati
# i parametri delle serie adia acenti "938" e "943"
#
unless (getvalues($s) and (! $opt_e)) {
    $mat1=substr($s,0,3);
    $mat2=substr($s,0,3);
    do {
	$mat1--;
	print "mat1: $mat1 \n" if $debug;
    } until (getvalues(sprintf '%03u',$mat1) or ($mat1 == 0));
    do {
	$mat2++;
	print "mat2: $mat2 \n" if $debug;
    } until (getvalues(sprintf '%03u',$mat2) or ($mat2 == 999));
}

for $i (0 .. $#sn1) {
    for $j (0 .. $#sn1) {
	for $k (0 .. $#sn1) {
	    print "$sn1[$i],$k[$j],$q[$k],$mac1[$i]\n" if $debug;
	    $serial=getserial($s,$sn1[$i],$k[$j],$q[$k]);
	    $serials{$serial}=1 if ($serial);
	    $mac1[$i]=lc $mac1[$i];
	    print "mac: $mac, mac1: $mac1, mac1[i]: $mac1[$i]\n" if $debug;
	    $preferred{$serial}=1 if ($serial and $mac and (($mac1 eq $mac1[$i]) or ($mac1[$i] eq 'xxxxxx')));
	    print "preferred: $preferred{$serial}\n" if $debug;
	}
    }
}

if ($mac) {
    @slist=sort keys %preferred;
} else {
    @slist=sort keys %serials;
}
   
for $k (@slist) {
    print $k,"\n";
}

exit;
