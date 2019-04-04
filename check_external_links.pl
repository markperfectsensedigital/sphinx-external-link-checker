#!/usr/bin/perl

use LWP::UserAgent;
use HTTP::Request::Common;
use strict;
use File::Find qw(finddepth);
# Disable verification of SSL host names. Required for checking URLs at https:// addresses
$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;

my @urls;
my @files;
finddepth(sub {
      return if($_ eq '.' || $_ eq '..');
		my $omg = $File::Find::name;
		if ($omg =~ m/\.html$/) {
      	push @files, $File::Find::name;
		}
}, '/Users/mlautman/Documents/docs/_build/html');

$/ = undef;
foreach (@files) {
	print ">>> Examining $_\n";
	#print "$_\n";
	open (my $html, "<$_") or die('Cannot open a file');
	my $hugefile = <$html>;
	my @localurls = $hugefile =~ m/http[s]?:\/\/.*?\.html/g;
	foreach my $bango (@localurls) {
		print "Checking for $bango inside @urls\n";
		my @newones = grep(/^$bango$/,@urls);
		print "The value of newones is @newones\n";
		if (!@newones) {
			print ("I found new ones: $bango\n");
			push (@urls,$bango);
		}
	}
	close ($html);
}
print "When it is all over, the URLs are\n";
print "@urls\n";
exit;

my $ua = LWP::UserAgent->new;

#my $response = $ua->head("http://localhost:82/index.htmx");
my $response = $ua->head('https://artifactory.psdops.com/psddev-releases/com/psddev/dari/3.2.2450-7be12b/dari-3.2.2450-7be12b-javadoc.jar!/com/psddev/dari/util/PasswordException.html');

print "Level 1\n";
    while ( my ($key, $value) = each(%$response) ) {
        print "$key => $value\n";
    }

print "Headers\n";
    while ( my ($key, $value) = each(%{$response->{'_headers'}}) ) {
        print "$key => $value\n";
    }
print "Request\n";
    while ( my ($key, $value) = each(%{$response->{'_request'}}) ) {
        print "$key => $value\n";
    }
print "Content type is " . $response->headers->header("Content-Type") . "\n";
print "Base is  is " . $response->base . "\n";
print "Code is  is " . $response->code. "\n";


