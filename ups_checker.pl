#!/usr/bin/perl

#
# Title: ups_checker.pl
# Author: Simon Ibsen (simon@engineering.ucsb.edu)
# Date: 6/8/11 
# Purpose: To do something with ups stats 
#
# Nagios exit status codes
# 0 = Normal
# 1 = Warning
# 2 = Critical
# 3 = Unknown
#

use Getopt::Std;

# Our options
getopt('HCowclpu');

my $host = $opt_H;

# SNMP community name
my $scn = $opt_C;

# SNMP MIB and OID
my $oid = $opt_o;

# Warning and critical values
my $warn = $opt_w;
my $critical = $opt_c;

# Description used in Status Information section
my $description = $opt_l;

# Performance Data Description
my $performance_data_desc = $opt_p;
my $data_unit = $opt_u;

# SNMP version - assumes v1
#my $snmp_version = 1;

# Require some basic arguments
if (not defined $opt_H,$opt_C,$opt_o,$opt_l)
{
	print "\nUsage: $0 -H hostname or IP -C SNMP community name -o OID -w Warning value -c Critical value -l Description -p Performance data description -u Unit\n\n";
        print "Example:\n";
	print "$0 -H 192.168.27.175 -C snmpcommunity -o .1.3.6.1.4.1.318.1.1.1.4.2.3.0  -w 80 -c 90 -l \"Current Load\" -p CurrentLoad -u \"%\"\n\n";
	exit;
}

# Open the pipe
open(CHECK, "/usr/bin/snmpget -c $scn -v1 $host $oid|");
while(<CHECK>)
{
        # Grab the result
       	if(/^SNMPv2-SMI.*:\s(.*)$/)
       	{
		$value = $1;
	}

	# Special cases
        # These have unique return values

        # Last Test Result
	if($oid eq ".1.3.6.1.4.1.318.1.1.1.7.2.3.0")
	{
                
                if($value eq  1)
                {
		        print "$description: Pass\n";
			exit 0;
		}elsif($value eq 2){
			# Test Fail
			print "$description: Fail\n";
			exit 2;
		}elsif($value eq 3){
			# Battery low
			print "$description: Unknown\n";
			exit 3;
                }
		 
	}
              
        # Last Test Date
	if($oid eq ".1.3.6.1.4.1.318.1.1.1.7.2.4.0")
	{
                # This could be expanded to test on age of test
		if($value eq "\"Unknown\"")
		{
                	print "$description: Unknown\n";
                	exit 3;
		}
		print "$description: $value\n";
		exit 0;
	}
	
        # Run Time 
	if($oid eq ".1.3.6.1.4.1.318.1.1.1.2.2.3.0")
	{
                # This could be expanded to test on runtime
		print "$description: $value\n";
		exit 0;
	}
	
	# Battery Status
	if($oid eq ".1.3.6.1.4.1.318.1.1.1.2.1.1.0")
	{
		if($value eq 1)
		{
			# Unknown
			print "$description is UNKNOWN: Unknown\n";
			exit 3;
			
		}elsif($value eq 2){
			# Battery normal
			print "$description is normal: Normal\n";
			exit 0;
		}elsif($value eq 3){
			# Battery low
			print "$description is Warning: Low\n";
			exit 1;
		}
	}	

	# Main UPS Status
	if($oid eq ".1.3.6.1.4.1.318.1.1.1.4.1.1.0")
	{
		if($value eq 1)
		{
			print "$description is UNKNOWN: Unknown\n";
			exit 3;
		}elsif($value eq 2){
			print "$description is normal: On Line\n";
			exit 0;
		}elsif($value eq 3){
			print "$description is CRITICAL: On Battery\n";
			exit 2;
		}elsif($value eq 4){
			print "$description is CRITICAL: On Smart Boost\n";
			exit 2;
		}elsif($value eq 5){
			print "$description is CRITICAL: Timed Sleeping\n";
			exit 2;
		}elsif($value eq 6){
			print "$description is CRITICAL: Software Bypass\n";
			exit 2;
		}elsif($value eq 7){
			print "$description is CRITICAL: Off\n";
			exit 2;
		}elsif($value eq 8){
			print "$description is CRITICAL: Rebooting\n";
			exit 2;
		}elsif($value eq 9){
			print "$description is CRITICAL: Switched Bypass\n";
			exit 2;
		}elsif($value eq 10){
			print "$description is CRITICAL: Hardware Failure Bypass\n";
			exit 2;
		}elsif($value eq 11){
			print "$description is CRITICAL: Sleeping Until Power Returns\n";
			exit 2;
		}elsif($value eq 12){
			print "$description is CRITICAL: On Smart Trim\n";
			exit 2;
		}
	}

        # Battery Replacment Status
	if($oid eq ".1.3.6.1.4.1.318.1.1.1.2.2.4.0")
	{
		if($value eq 1)
		{
			# Test Pass
			print "$description is normal: Does not need replacing\n";
			exit 0;
		}elsif($value eq 2){
			# Test Fail
			print "$description is CRITICAL: Need replacing\n";
			exit 1;
                }
	}

        # The rest are generic numeric cases, some where a higher value is better, 
        # some where a lower value is better.
        
        #
        # More is better
        #

        # Battery Charge
	# ".1.3.6.1.4.1.318.1.1.1.2.2.1.0"

	if($oid eq ".1.3.6.1.4.1.318.1.1.1.2.2.1.0")
        {
             if($value > $warn)
             {
                     print "$description is normal: $value $data_unit|$performance_data_desc=$value\n";
                     exit 0;
             }
             elsif($value <= $warn and $value > $critical)
             {
                     print "$description is Warning: $value $data_unit|$performance_data_desc=$value\n";
                     exit 1;
             }
             elsif($value <= $critical)
             {
                     print "$description is CRITICAL: $value $data_unit|$performance_data_desc=$value\n";
                     exit 2;
             }
             else #Unknown
             {
                     print "$description is in an unknown state!";
                     exit 3;
             }
        }
        
        #
        # Less is better
        #

        # Current Load
        # .1.3.6.1.4.1.318.1.1.1.4.2.3.0

        # Internal Temperature
        # .1.3.6.1.4.1.318.1.1.1.2.2.2.0

	# Ambient Temperature
	# .1.3.6.1.4.1.318.1.1.25.1.2.1.5.1.1

        @lOIDs = qw/.1.3.6.1.4.1.318.1.1.1.4.2.3.0 .1.3.6.1.4.1.318.1.1.1.2.2.2.0 .1.3.6.1.4.1.318.1.1.25.1.2.1.5.1.1/;

        if(grep $_ eq $oid, @lOIDs)
        {
             if($value < $warn)
             {
                     print "$description is ok: $value $data_unit|$performance_data_desc=$value\n";
                     exit 0;
             }
             elsif($value => $warn and $value < $critical)
             {
                     print "$description is Warning: $value $data_unit|$performance_data_desc=$value\n";
                     exit 1;
             }
             elsif($value => $critical)
             {
                     print "$description is CRITICAL: $value $data_unit|$performance_data_desc=$value\n";
                     exit 2;
             }
             else #Unknown
             {
                     print "$description is in an unknown state!";
                     exit 3;
             }
        }

	# If we have arrived here then something is not accounted for
        print "$description is in an unknown state or $0 doesn't know about this OID!\n";
        exit 3;
}
# If we have arrived here then something is not accounted for
print "$description is in an unknown state or $0 doesn't know about this OID!\n";
exit 3;
