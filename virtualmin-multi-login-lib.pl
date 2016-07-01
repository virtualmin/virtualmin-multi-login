# Login functions
use strict;
use warnings;

BEGIN { push(@INC, ".."); };
eval "use WebminCore;";
&init_config();
&foreign_require("server-manager", "server-manager-lib.pl");

# find_vm2_server(username|domain, password)
# Given a username or domain name, get from VM2 the server and domain objects
# for it. Return an array of 2-element array refs.
sub find_vm2_server
{
my ($user, $pass) = @_;
my @rv;
foreach my $s (&server_manager::list_managed_servers()) {
	my @doms = &server_manager::get_server_domains($s);
	foreach my $d (@doms) {
		if (!$d->{'parent'} &&
		    ($d->{'user'} eq $user || $d->{'dom'} eq $user ||
		     "www.".$d->{'dom'} eq $user)) {
			my $rank = $s->{'status'} eq 'down' ||
				   $s->{'status'} eq 'nossh' ||
				   $s->{'status'} eq 'nowebmin' ||
				   $s->{'status'} eq 'downwebmin' ? 0 :
				    $d->{'pass'} ne $pass ? 1 : 2;
			push(@rv, [ $s, $d, $rank ]);
			}
		}
	}

# Sort results. Those on up systems come first, then those with the correct pass
@rv = sort { $b->[2] <=> $a->[2] } @rv;

return @rv;
}

# match_domain_pass(&domain, password)
# Return 1 if some plaintext password is valid for a domain
sub match_domain_pass
{
my ($d, $pass) = @_;
if ($d->{'pass'}) {
	# Plaintext password is known
	return $d->{'pass'} eq $pass;
	}
elsif ($d->{'enc_pass'}) {
	# Check against encrypted password
	&foreign_require("useradmin");
	return &useradmin::validate_password($pass, $d->{'enc_pass'});
	}
return 0;
}

1;
