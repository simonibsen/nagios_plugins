#!/usr/bin/perl
#
# -Simon Ibsen
# 
# A little check to get ave load using snmp, with perf data (which is 
# broken in check_snmp plugin)

# Written generically for future usage
#
#

use strict;
use Getopt::Std;

our($opt_P,$opt_C,$opt_h,$opt_m,$opt_d,$opt_D,$opt_w,$opt_c);
getopt('PChmdDwc');

my $protocol = $opt_P;
my $cname = $opt_C;
my $host = $opt_h;
my $MIB = $opt_m;
my $description = $opt_d;
my $Perfdescription = $opt_D;
my $warn = $opt_w;
my $critical = $opt_c;

if (not defined $opt_P,$opt_C,$opt_h,$opt_m,$opt_d,$opt_D,$opt_w,$opt_c)
{
        print "\nUsage: $0 -P protocol (1,2,2c) -C CommunityName -h host -m MIB -d Descriptive String -D \"Performance Descriptive String\" -w Warning value -c Critical value\n\n";
        exit;
}

open(CHECK, "/usr/bin/snmpget -c $cname -v $protocol $host $MIB|");
while(<CHECK>)
{
	chomp;
        if(/.*:(.*)$/)
        {
                my $value = $1;

       		if($value < $warn)
        	{
                	print "$description OK: $value|$Perfdescription=$value\n";
                	exit 0;
        	}
       	 	elsif(($value=>$warn) and ($value<$critical))
		{
                	print "$description Warning: $value|$Perfdescription=$value\n";
			exit 1;
		}
		elsif($value > $critical)
		{
                	print "$description Critical: $value|$Perfdescription=$value\n";
			exit 2;
		}
	}
}
# If we've made it this far something is wrong
print "Unknown state! Debug: $opt_P,$opt_C,$opt_h,$opt_m,$opt_d,$opt_D,$opt_w,$opt_c";
exit 3;
