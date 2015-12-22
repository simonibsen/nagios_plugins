#!/usr/bin/perl

# Title: quota_check.pl
# Author: Simon Ibsen (simon@engineering.ucsb.edu)
# Date: 6/2/13 
# Purpose: Check a user's quota
#
# Nagios exit status codes
# 0 = Normal
# 1 = Warning
# 2 = Critical
# 3 = Unknown
#

use Getopt::Std;

# Our options
getopt('wcu');

# Warning and critical values
my $warn = $opt_w;
my $critical = $opt_c;

# The user whose quota we care about
my $user = $opt_u;

my $i; #counter

# Let's make sure that the appropriate file system is actually mounted

system("cd ~$user/.." or die "cannot change: $!\n");

open(CHECK_QUOTA, "/usr/bin/sudo /usr/bin/quota $user|");

while (<CHECK_QUOTA>) {
     $i++;
     # We want the fourth line of output
     if($i eq 4){
          if(/(\d+)\*?\s+(\d+)\s+(\d+)\s+\w*\s+(\d+)\*?\s+(\d+)\s+(\d+)/)
          {

               # These are our block values of interest
               $block_usage = $1;
               $block_quota = $2;

               $block_quota_usage = sprintf("%.2f", ($block_usage / $block_quota) * 100);

               # These are our inode values of interest
               $inode_usage = $4;
               $inode_quota = $5;

               $inode_quota_usage = sprintf("%.2f", ($inode_usage / $inode_quota) * 100);

               # Let's see where we fall
               if(($block_quota_usage < $warn) and ($inode_quota_usage < $warn))
               {
                    print "$user Quota OK - Block Quota=$block_quota_usage% ($block_usage/$block_quota) - Inode Quota=$inode_quota_usage% ($inode_usage/$inode_quota)|BlockQuota=$block_quota_usage% InodeQuota=$inode_quota_usage%\n";
                    exit 0;
               }
               elsif((($block_quota_usage => $warn) or ($inode_quota_usage => $warn)) and (($block_quota_usage < $critical) and ($inode_quota_usage < $critical)))
               {
                    print "$user Quota Warning - Block Quota=$block_quota_usage% ($block_usage/$block_quota) - Inode Quota=$inode_quota_usage% ($inode_usage/$inode_quota)|BlockQuota=$block_quota_usage% InodeQuota=$inode_quota_usage%\n";
                    exit 1;
               }
               elsif(($block_quota_usage or $inode_quota_usage) => $critical)
               {
                    print "$user Quota Critical - Block Quota=$block_quota_usage% ($block_usage/$block_quota) - Inode Quota=$inode_quota_usage% ($inode_usage/$inode_quota)|BlockQuota=$block_quota_usage% InodeQuota=$inode_quota_usage%\n";
                    exit 2;
               }
               else #Unknown
               {
                    print "$user Quota is in an unknown state!";
                    exit 3;
               }

          }
     }
}

# If we have made it this far something has gone awry
print "$user Quota is in an unknown state!";
exit 3;
