#!/usr/bin/perl

#
# Title: spamass_stat.pl
# Version: 1.00
# Author: Simon Ibsen (simon@engineering.ucsb.edu)
# Date: 3/2/11 
# Purpose: To do something with spamassassin data stored in db
#
#

use Getopt::Std;
use DBI;

# Our options
getopt('hwcCp');

my $host = $opt_h;
my $check_type = $opt_C;
my $warn = $opt_w;
my $critical = $opt_c;
my $period_minutes = $opt_p;

if (not defined $opt_h,$opt_C,$opt_w,$opt_c,$opt_p)
{
	print "\nUsage: $0 -h hostname -C check_type -w Warning value -c Critical value -p Polling period in minutes\n";
	print "\tWhere check_type is one of spam_count, spam_percentage, ham_count,\n"; 
	print "\tmessage_count, scan_time, average_score, average_ham_score, average_ham_score\n\n";
	exit;
}


# Open single db connection
my $dbh = DBI->connect("DBI:mysql:sqlsyslogd", "sqlsyslogd", "secret");

# If check type is spam count
if($check_type eq "spam_count"){
	my $sth = $dbh->prepare('select count(*) as spam from logs where host=? and timestamp > unix_timestamp(date_sub(now(), interval ? minute)) and message like \'%spamd: result: Y%\' order by timestamp');
	$sth->execute($host,$period_minutes);
	while (@data = $sth->fetchrow_array()) 
	{
		my $stat = $data[0];	
		if($stat < $warn)
		{
			print "Spam Count Ok: $stat|SpamCount=$stat\n";
			exit 0;
		}
		elsif($stat > $warn and $stat < $critical)
		{
			print "Spam Count Warning: $stat|SpamCount=$stat\n";
			exit 1;
		}
		elsif($stat> $critical)
		{
			print "Spam Count Critical: $stat|SpamCount=$stat\n";
			exit 2;
		}
		else #Unknown
		{
			exit 3;
		}
	}
}

#
if($check_type eq "ham_count"){
	my $sth = $dbh->prepare('select count(*) as ham from logs where host=? and timestamp > unix_timestamp(date_sub(now(), interval ? minute)) and message like \'%spamd: result: .%\' order by timestamp');
	$sth->execute($host,$period_minutes);
	while (@data = $sth->fetchrow_array()) 
	{
		my $stat = $data[0];	
		if($stat < $warn)
		{
			print "Ham Count Ok: $stat|HamCount=$stat\n";
			exit 0;
		}
		elsif($stat > $warn and $stat < $critical)
		{
			print "Ham Count Warning: $stat|HamCount=$stat\n";
			exit 1;
		}
		elsif($stat> $critical)
		{
			print "Ham Count Critical: $stat|HamCount=$stat\n";
			exit 2;
		}
		else #Unknown
		{
			exit 3;
		}
	}
}
if($check_type eq "message_count"){
	my $sth = $dbh->prepare('select count(*) from logs where host=? and timestamp > unix_timestamp(date_sub(now(), interval ? minute)) and message like \'%spamd: result:%\' order by timestamp');
	$sth->execute($host,$period_minutes);
	while (@data = $sth->fetchrow_array()) 
	{
		my $stat = $data[0];	
		if($stat < $warn)
		{
			print "Message Count Ok: $stat|MessageCount=$stat\n";
			exit 0;
		}
		elsif($stat > $warn and $stat < $critical)
		{
			print "Message Count Warning: $stat|MessageCount=$stat\n";
			exit 1;
		}
		elsif($stat> $critical)
		{
			print "Message Count Critical: $stat|MessageCount=$stat\n";
			exit 2;
		}
		else #Unknown
		{
			exit 3;
		}
	}
}

if($check_type eq "spam_percentage"){

	my $sth = $dbh->prepare('select count(*) as spam from logs where host=? and timestamp > unix_timestamp(date_sub(now(), interval ? minute)) and message like \'%spamd: result: Y%\' order by timestamp');
	$sth->execute($host,$period_minutes);
	while (@data = $sth->fetchrow_array()) 
	{
		$spam = $data[0];	
	}

	$sth = $dbh->prepare('select count(*) as total from logs where host=? and timestamp > unix_timestamp(date_sub(now(), interval ? minute)) and message like \'%spamd: result:%\' order by timestamp');
	$sth->execute($host,$period_minutes);
	while (@data = $sth->fetchrow_array()) 
	{
		$total = $data[0];	
	}

	$spam_per = sprintf("%.2f", ($spam / $total) * 100);
	if($spam_per < $warn)
        {
                print "Spam Percentage Ok: $spam_per|SpamPercentage=$spam_per\n";
                exit 0;
        }
        elsif($spam_per > $warn and $spam_per < $critical)
        {
                print "Spam Percentage Warning: $spam_per|SpamPercentage=$spam_per\n";
                exit 1;
        }
        elsif($spam_per> $critical)
        {
                print "Spam Percentage Critical: $spam_per|SpamPercentage=$spam_per\n";
                exit 2;
        }
        else #Unknown
        {
                exit 3;
        }
}


if($check_type eq "scan_time"){
	my $sth = $dbh->prepare('select * from logs where host=? and timestamp > unix_timestamp(date_sub(now(), interval ? minute)) and message like \'%spamd: result:%\' order by timestamp');
	$sth->execute($host,$period_minutes);

	while (@data = $sth->fetchrow_array()) 
	{
		$count++;
		$output = $data[5];	
		@stats = split(/\s/, $output);
		$stats[6] =~ m/scantime=(\d*\.\d*),/;
		$total = $1 + $total;
	}
	$average = sprintf("%.2f", ($total / $count));
	if($average < $warn)
        {                        
		print "Average Scan Time Ok: $average|AverageScanTime=$average\n";
                exit 0;
        }
        elsif($average > $warn and $average < $critical)
        {
		print "Average Scan Time Warning: $average|AverageScanTime=$average\n";
                exit 1;
        }
        elsif($stat> $critical)
        {
		print "Average Scan Time Critical: $average|AverageScanTime=$average\n";
                exit 2;
        }
        else #Unknown
        {
        	exit 3;
        }
}
# Not counting white listed entries
if($check_type eq "average_score"){
	my $sth = $dbh->prepare('select * from logs where host=? and timestamp > unix_timestamp(date_sub(now(), interval ? minute)) and message like \'%spamd: result:%\' and message not like \'%IN_WHITELIST%\' order by timestamp');
	$sth->execute($host,$period_minutes);

	while (@data = $sth->fetchrow_array()) 
	{
		$count++;
		$output = $data[5];	
		@stats = split(/\s/, $output);
		$score = $stats[3];	
		$total = $score + $total;
	}
	$average = sprintf("%.2f", ($total / $count));
	if($average < $warn)
        {                        
		print "Average Score Ok: $average|AverageScore=$average\n";
                exit 0;
        }
        elsif($average > $warn and $average < $critical)
        {
		print "Average Score Warning: $average|AverageScore=$average\n";
                exit 1;
        }
        elsif($stat> $critical)
        {
		print "Average Score Critical: $average|AverageScore=$average\n";
                exit 2;
        }
        else #Unknown
        {
        	exit 3;
	}
}

# Not counting white listed entries
if($check_type eq "average_spam_score"){
	my $sth = $dbh->prepare('select * from logs where host=? and timestamp > unix_timestamp(date_sub(now(), interval ? minute)) and message like \'%spamd: result: Y%\' order by timestamp');
	$sth->execute($host,$period_minutes);

	while (@data = $sth->fetchrow_array()) 
	{
		$count++;
		$output = $data[5];	
		@stats = split(/\s/, $output);
		$score = $stats[3];	
		$total = $score + $total;
	}
	$average = sprintf("%.2f", ($total / $count));

	if($average < $warn)
        {                        
		print "Average Spam Score Ok: $average|AverageSpamScore=$average\n";
                exit 0;
        }
        elsif($average > $warn and $average < $critical)
        {
		print "Average Spam Score Warning: $average|AverageSpamScore=$average\n";
                exit 1;
        }
        elsif($stat> $critical)
        {
		print "Average Spam Score Critical: $average|AverageSpamScore=$average\n";
                exit 2;
        }
        else #Unknown
        {
        	exit 3;
	}
}
# Not counting white listed entries
if($check_type eq "average_ham_score"){
	my $sth = $dbh->prepare('select * from logs where host=? and timestamp > unix_timestamp(date_sub(now(), interval ? minute)) and message like \'%spamd: result: .%\' and message not like \'%IN_WHITELIST%\' order by timestamp');
	$sth->execute($host,$period_minutes);

	while (@data = $sth->fetchrow_array()) 
	{
		$count++;
		$output = $data[5];	
		@stats = split(/\s/, $output);
		$score = $stats[3];	
		$total = $score + $total;
	}
	$average = sprintf("%.2f", ($total / $count));

	if($average < $warn)
        {                        
		print "Average Ham Score Ok: $average|AverageHamScore=$average\n";
                exit 0;
        }
        elsif($average > $warn and $average < $critical)
        {
		print "Average Ham Score Warning: $average|AverageHamScore=$average\n";
                exit 1;
        }
        elsif($stat> $critical)
        {
		print "Average Ham Score Critical: $average|AverageHamScore=$average\n";
                exit 2;
        }
        else #Unknown
        {
        	exit 3;
	}
}
exit 3; # We got no result...

# Done
$dbh->disconnect;
