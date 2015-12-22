#!/usr/bin/perl 
#
# Simon Ibsen
#
# Nagios nrpe check on the replication slave status
#

use strict;
use Sys::Hostname;

# Readonly backup user
my $user = "backup";
my $password = "secret";

# This is the allowable lag for the
# slave to be behind the master
my $okay_lag_time = 4000;

my $checked;
my @master_data; 
my $master;
my $hostname = hostname();

open(MYSQL_REPL_CHECK, "/usr/bin/mysql -u $user --password=\"$password\" -e \"show slave status\\G\"|");
while(<MYSQL_REPL_CHECK>)
{
	chomp;

	if(/Master_Host/)
	{
		@master_data = split(/:\s/);
		$master = $master_data[1];
	}
	if(/Seconds_Behind_Master/)
	{
		my @data = split(/:\s/);
		if ($data[1] > $okay_lag_time )
		{
			print "Mysql replication problem on $hostname - $data[1] seconds behind master: $master";
			exit 1
		}
		elsif($data[1] eq "NULL")
		{
			# For NULL does not equal zero
			print "$hostname - NULL seconds behind master: $master - REPLICATION MAY BE BROKEN";
			exit 2
		}
		else
		{
			print "Mysql replication working fine on $hostname - $data[1] seconds behind master: $master";
			exit 0
		}
		$checked = 1;
	}
}
close(MYSQL_REPL_CHECK);

if($checked != 1)
{
	print "$hostname for master: $master - Check failed";
	exit 3
}
