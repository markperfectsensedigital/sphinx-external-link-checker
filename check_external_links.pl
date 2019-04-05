#!/usr/bin/perl

die "\nUsage: $0 <directory containing _build/html/>\n\n" if @ARGV < 1;

my $user_directory = $ARGV[0];
my $build_directory = $ARGV[0] . '/_build/html/';
# Remove trailing slashes.
$build_directory =~ s/\/\//\//gc;

print "\nChecking $build_directory...";

if (-e $build_directory and -d $build_directory) {
	print "exists!\n\n";
} else {
	print "\n\nThe directory $user_directory does not exist,\n";
	print "or does not contain the subdirectories _build/html. Try another directory?\n\n.";
	exit;
}

use LWP::UserAgent;
use HTTP::Request::Common;
use strict;
use File::Find qw(finddepth);
# Disable verification of SSL host names. Required for checking URLs at https:// addresses
$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;

#Holds list of all .html files produced by Sphinx in _build/html
my @files;

#Hash: key is the URL, value is two fields:
#  rc - HTTP response code
#  msg - HTTP message
my %newurls;

# Find full path/filename of all html files created by Sphinx.
# Ignore any such files starting with . or ... Such files are
# x-refs to other HTML files created by Sphinx, and are validated
# at build time.
finddepth(sub {
      return if($_ eq '.' || $_ eq '..');
		my $omg = $File::Find::name;
		if ($omg =~ m/\.html$/) {
      	push @files, $File::Find::name;
		}
}, '/Users/mlautman/Documents/docs/_build/html');

# Create new user agent
my $ua = LWP::UserAgent->new;

# Required for slurping
$/ = undef;

# For each found HTML file, extract all the URLs and place them
# as keys into the hash %newurls.
foreach (@files) {
	print ">>> Examining $_\n";
	open (my $html, "<$_") or die('Cannot open a file');
	# Slurp
	my $hugefile = <$html>;

	# Match any string surrounded by href=".*" that starst with a word char (avoids local
	# files starting with ..)
	my @hrefs = $hugefile =~ m/href=\"\w*:\/\/.*?"/g;

	# Isolate the URL inside href=".*"
	s/href="(.*)"/$1/ for  @hrefs;

	# Insert the found URLs as keys into the hash %newurls.
	# There are many duplicate URLs in Sphinx output. As Perl
	# allows only unique keys in a hash, we are assured that
	# each URL appears only once. (There probably a faster way to
	# avoid duplicates than clobbering existing keys.)
	foreach my $localurl (@hrefs) {
		$newurls{$localurl} = {'rc' => 0, 'msg' =>''};
	}
	close ($html);
}

# For each URL in the hash %newurls, perform a HEAD
# request and record the resulting response code and message.
foreach (keys %newurls) {
	print "Retrieving HEAD for $_\n";
	my $response = $ua->head($_);
	$newurls{$_} = {
		'rc' => $response->{'_rc'},
		'msg' => $response->{'_msg'}
	};
}


# Print results.
open (my $outfile,'>/tmp/url_list.csv') || die "Cannot open output file\n";
print $outfile "URL\tResponse Code\tMessage\n";
foreach (sort keys %newurls) {
	print $outfile "$_\t$newurls{$_}{'rc'}\t$newurls{$_}{'msg'}\n"; 
	
}

close $outfile;
print "\nAll done! Results in /tmp/url_list.csv\n\n";
