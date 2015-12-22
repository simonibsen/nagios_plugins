#!/usr/bin/perl -wall
#
# -Simon Ibsen
# A little check to get port status on a switch using snmp
#

chomp($switch = <$ARGV[0]>);
chomp($port = <$ARGV[1]>);
chomp($description_name = <$ARGV[2]>);

open(INFCHECK, "/usr/bin/snmpget -c snmpcommunity -v 1 $switch ifAdminStatus.$port|");
while(<INFCHECK>)
{
	chomp;
        if(/.*\sup\(\d\)/)
        {
                print "Interface Test: $description_name is Up!";
                exit 0;
        }
        elsif(/.*\sdown\(\d\)/)
	{
                print "Interface Test: $description_name is Down!";
		exit 2;
	}
	else
	{
                print "Interface Test: $description_name is in an unknown state!";
		exit 3;
	}
}
# If we've made it this far something is wrong
print "Unknown state!";
exit 3;
