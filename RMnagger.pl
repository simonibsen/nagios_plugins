#!/usr/bin/perl 
#
# Title: RMnagger.pl
# Version: 
# Author: Simon Ibsen (simon@engineering.ucsb.edu)
# Purpose: To check if a host is in RackMap
#
#

use Getopt::Std;
use DBI;
use strict;

our $opt_h;

# Our options
getopt('h');

my $host = $opt_h;

if (not defined $host)
{
	print "\nUsage: $0 -h hostname\n";
	exit;
}


# Open single db connection
my $dbh = DBI->connect("DBI:mysql:rackmaster", "backup", "secret");
my $statement = "select obj_obt_id from rm_objects where obj_name like '%$host'";
my @data = $dbh->selectrow_array($statement);
if(@data)
{
	print "Host: $host is in RackMap\n";
	exit 0;
}
else
{
	print "Host: $host is not in RackMap - Disappointing...\n";
	exit 2;	
}

# Done
$dbh->disconnect;
