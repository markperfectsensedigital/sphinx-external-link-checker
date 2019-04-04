#!/usr/bin/perl

use LWP::UserAgent;
use HTTP::Request::Common;
# Disable verification of SSL host names. Required for checking URLs at https:// addresses
$ENV{'PERL_LWP_SSL_VERIFY_HOSTNAME'} = 0;
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


