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

use Digest::SHA qw(sha256 sha256_hex);
use Getopt::Std;

sub usage {
    print "usage: sermac2wpa.pl [-q] -s serial -m mac-address \n";
    print "  -q   quite operation, solo le password\n";
    print "example: sermac2wpa -s 67902X0000001  -m 6487d70ae9f1\n";
    exit;
}

getopts('s:m:q');

$s = $opt_s or usage;
$mac= $opt_m or usage;
$mac= uc $mac;
$mac=~s/[\:\-]//g;
($sn1,$sn2) = split /X/,$s;

die "Errore nel mac address $mac \n" unless ($mac=~/^[0-9a-f]{12}$/i);
die "Errore nel seriale $opt_s\n"    unless (($sn1=~/^\d{5}$/) and ($sn2=~/^\d{7}$/));

$fixed="64C6DDE3E579B6D986968D3445D23B15CAAF128402AC560005CE2075913FDCE8";

$charset = "0123456789abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz"
         . "0123456789abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz"
         . "0123456789abcdefghijklmnopqrstuvwxyz0123456789abcdefghijklmnopqrstuvwxyz"
         . "0123456789abcdefghijklmnopqrstuvwxyz0123";
@charset=split //,$charset;

print "serial: $s\n" unless $opt_q;
print "mac:    $mac\n" unless $opt_q;
@machex    = ($mac =~ /(..)/g);
@macdec    = map { hex($_) } @machex;

@fixedhex    = ($fixed =~ /(..)/g);
@fixeddec    = map { hex($_) } @fixedhex;

$sfixed=pack("C*",@fixeddec);
$smac=  pack("C*",@macdec);

$digest=sha256($sfixed, $s, $smac);
for $j (0 .. 23) {
    print $charset[ord(substr($digest,$j,1))];
}
print "\n";




