#!/usr/bin/perl

# --------------------------------------------------
# ARGV[0] = &lt;hostname&gt;     required
# ARGV[1] = &lt;username&gt;     required
# ARGV[2] = &lt;password&gt;     required
# --------------------------------------------------

# verify input parameters
my $in_hostname         = $ARGV[0] if defined $ARGV[0];
my $in_username         = $ARGV[1] if defined $ARGV[1];
my $in_password         = $ARGV[2] if defined $ARGV[2];

# usage notes
if (
        ( ! defined $in_hostname ) ||
        ( ! defined $in_username ) ||
        ( ! defined $in_password )
        ) {
        print   "usage:\n\n
                $0 &lt;host&gt; &lt;username&gt; &lt;password&gt; &lt;version&gt;\n\n";
        exit;
}

#get data from the nagios script
$result = `/usr/bin/perl /srv/eyesofnetwork/nagios-3.0.6/plugins/check_esx3.pl -H $in_hostname -u $in_username -p $in_password -l cpu -s usage`;

#find a result in the returned string
$result =~ /(.*=)([0-9]*.[0-9]*)(.*)/;

if ($2 == "") {
	print "U"; 		# avoid cacti errors, but do not fake rrdtool stats
}
else{
	print $2;
}
