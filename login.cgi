#!/usr/local/bin/perl
# Find the correct server, then redirect to it
use strict;
use warnings;
our (%text, %in, %config);

our $trust_unknown_referers = 1;
require './virtualmin-multi-login-lib.pl';
&ReadParse();

# Validate and normalize inputs
$in{'user'} = lc($in{'user'});
$in{'user'} =~ s/^\s+//;
$in{'user'} =~ s/\s+$//;
$in{'user'} =~ /\S/ || &error_redirect($text{'login_euser'});
$in{'user'} =~ /^\S+$/ || &error_redirect($text{'login_euser2'});
$in{'pass'} =~ /\S/ || &error_redirect($text{'login_epass'});

# See if the user exists
my @matches = &find_vm2_server($in{'user'}, $in{'pass'});
@matches || &error_redirect($text{'login_efind'});

# Is the server up?
my ($s, $d) = @{$matches[0]};
if ($s->{'status'} eq 'down' || $s->{'status'} eq 'nossh' ||
    $s->{'status'} eq 'nowebmin' || $s->{'status'} eq 'downwebmin') {
	&error_redirect($text{'login_edown'});
	}

# Does the login work?
my %miniserv;
&get_miniserv_config(\%miniserv);
my $host = !$config{'hostname'} ? $d->{'dom'} :
	!$s->{'host'} ? &get_system_hostname() : $s->{'host'};
my ($out, $err);
&http_download($host, $s->{'port'} || $miniserv{'port'}, "/", \$out, \$err,
	       undef, $s->{'ssl'}, $d->{'user'}, $in{'pass'});
if ($err =~ /401/) {
	&error_redirect($text{'login_ewrong'});
	}
elsif ($err) {
	&error_redirect(&text('login_econnect',
		$host, $s->{'port'} || $miniserv{'port'}));
	}

# Redirect the user to the correct machine
my $url = ($s->{'ssl'} ? "https://" : "http://").
       $host.
       ":".($s->{'port'} || $miniserv{'port'}).
       "/session_login.cgi?".
       "user=".&urlize($d->{'user'})."&".
       "pass=".&urlize($in{'pass'}).
       "&notestingcookie=1";
my $sec = $s->{'ssl'} ? "; secure" : "";
print "Set-Cookie: testing=1; domain=$host; path=/$sec\r\n";
&redirect($url);

sub error_redirect
{
my $ref = $ENV{'HTTP_REFERRER'};
$ref =~ s/\?.*$//;
$ref ||= "index.cgi";
&redirect($ref."?user=".&urlize($in{'user'})."&err=".&urlize($_[0]));
exit(0);
}
