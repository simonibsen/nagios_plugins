#!/usr/bin/perl
#
# -Simon Ibsen
# A simple check to get the temperature on a Cisco 6500 switch using snmp
#

# Expects the name of the swich, the MIB, the MIB index, and a descriptive value

use Getopt::Std;

getopt('smidwc');

my $switch = $opt_s;
my $MIB = $opt_m;
my $MIBindex = $opt_i;
my $description = $opt_d;
my $warn = $opt_w;
my $critical = $opt_c;

if (not defined $opt_s,$opt_m,$opt_i,$opt_d,$opt_w,$opt_c)
{
	print "\nUsage: $0 -s switch -m MIB -i MIB index -d Descriptive String -w Warning value -c Critical value\n\n";
	exit;
}

open(CHECK, "/usr/bin/snmpget -c snmpcommunity -v 1 $switch $MIB.$MIBindex|");
while(<CHECK>)
{
        if(/^SNMPv2-SMI.*INTEGER:\s(\d*)$/)
        {
		$temp = $1;
		
		# Convert to Fahrenheit
		$temp =  ((9/5)*$temp)+32;

		if($temp < $warn)
		{
			print "$description Temp: $temp F|Temp=$temp\n";
			exit 0;
		}
		elsif($temp > $warn and $temp < $critical)
		{
			print "$description Temp: $temp F|Temp=$temp\n";
			exit 1;
		}
		elsif($temp > $critical)
		{
			print "$description Temp: $temp F|Temp=$temp\n";
			exit 2;
		}
		else #Unknown
		{
                	print "$description is in an unknown state!";
			exit 3;
		}

        }
	else
	{
                print "$description is in an unknown state!";
		exit 3;
	}
}
# If we've made it this far something is wrong
print "$description is in an unknown state!";
exit 3;
