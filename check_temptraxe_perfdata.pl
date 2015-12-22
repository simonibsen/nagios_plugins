#!/usr/bin/perl
# Simon Ibsen
use Getopt::Std;

use strict;

our($opt_H,$opt_p,$opt_w,$opt_c);

getopt('Hpwc');

#../libexec/check_temptraxe -H 3152temp.asdf.com -p 1 -w 68 -c 75
# Temp Ok: Probe 1 = 65.9 F

open (CHECKTEMP, "/usr/lib/nagios/plugins/check_temptraxe -H $opt_H -p $opt_p -w $opt_w -c $opt_c|");
while (<CHECKTEMP>)
{
	chomp;
	print $_;
	my @values = split;
	print "|Temp=$values[-2]\n";
	if (/Ok/)
	{
       		exit 0;
	}
	if (/Warning/)
	{
        	exit 1;
	}
	if (/Critical/)
	{
       		exit 2;
	}
	else #Unknown
	{
        	exit 3;
	}
}
# If we've made it this far something is wrong
print "Unknown state!";
exit 3;
