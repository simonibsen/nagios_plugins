#!/usr/bin/perl -wall
#
# -Simon Ibsen
# A little check to see if iptables be up 
#

# 0 = on
# 2 = off
# 3 = unknown
# 4 = on but not yet known if configured (not a valid Nagios exit code)

# Let's start with the known unknown, that is to say that which we don't know
# REF: http://en.wikipedia.org/wiki/There_are_known_knowns
my $status = 3;

open(IPFCHECK, "/usr/bin/sudo /sbin/iptables -L -n --line-numbers|");
while(<IPFCHECK>)
{
	if(/^Chain INPUT/)
	{
		# Iptables is on but we don't know if with any rules
		$status = 4;
	}
	# This will be our first rule when listing rules numerically
        if(/^1/)
        {
		# Yes, we got some rules
		$status = 0;
        }
        if(/Stopped/)
	{
		# No, we aren't on
		$status = 2;
	}
}
if($status eq "0")
{
	print "Firewall is up";
       	exit $status;

}elsif(($status eq "2") or ($status eq "4")){
	print "Firewall is off or not configured!";
	exit 2;
}

# If we've made it this far we remain a known unknown
print "Unknown state!";
exit $status;
