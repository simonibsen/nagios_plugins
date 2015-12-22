# nagios_plugins

A collection of Nagios plugions

**check_temptraxe_perfdata.pl**

A version of the temptraxe plugin with performance data.

**generic_port_test.pl**

A generic port(s) checker.  Can be used with multiple ports just to see if something is there.

**interface_check.pl**

Check to see if a specific switch interface is up.

**iptables_check.pl**

Check to make sure iptables is running.  Requires NRPE.

**mysql_replication_check.pl**

Check to make sure MySQL replication is functioning.  Requires NRPE.

**quota_check.pl**

Check if user is approaching the file quota.  Requires NRPE.

**RMnagger.pl**

Check if a host has been added to RackMap.  Run on host with Rackmap installed or change DB vars.

**snmpPerf_check.pl**

SNMP based check for load providing performance data.

**snmp_temp_check.pl**

SNMP based check to get temp values on a Cisco 6500 as performance data.

**spamass_stat.pl**

A check polling data out of MySQL database.  In this case Spamassasin data was being queried but it could be extended to any ole thing.

**ups_checker.pl**

A check polling UPS stats using SNMP.
