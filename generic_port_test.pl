#!/usr/bin/perl 
#
# Simon Ibsen
# Bare bones port listening check
#

use Getopt::Std;
getopt('hp');

# Get host and ports
my $host = $opt_h;
my $port = $opt_p;

# If we don't have host or ports remind user of usage
if(not defined($port) or not defined($host))
{
	print "\nUsage: $0 -h hostname -p port\n\n";
	print "Where port can be any number of comma separated ports\n\n";
	print "Example: $0 -h www.asdf.com -p 80,443,22\n\n";
	exit;
}

# Get list of ports
@ports = split(/,/,$port);

# Probe
open(NMAP, "/usr/bin/nmap -v -P0 -T2 -p $port $host|");


while(<NMAP>){
	foreach $p (@ports){
		if(/.*$p.*\sopen\s/){
			# Var for printing state
			$up_port = $up_port." $p";
		
			# Mark up ports
			$seen{$p} = "up";	
		}
	}
}

# Check if any ports in ports list should be marked as down
foreach $p (@ports){
	if (!exists $seen{$p}){
		# Var for printing state
		$down_port = $down_port." $p";

		# Set error condition
		$error = 1;
	}
}

if(defined $up_port){
	print "Port(s)$up_port on $host up";
	if (not defined $error){
		print "\n";
	}
}

if(defined $error){
	if(defined $up_port){
		print " but port(s)$down_port down\n";
	}
	else{
		print "Port(s)$down_port on $host down\n";
	}
	# Exit with Nagios error 
	exit 2;
}
else{
	# Exit with Nagios error 
	exit 0;
}
