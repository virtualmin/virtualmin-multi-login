# Login functions

do '../web-lib.pl';
&init_config();
do '../ui-lib.pl';
&foreign_require("server-manager", "server-manager-lib.pl");

# find_vm2_server(username|domain, password)
# Given a username or domain name, get from VM2 the server and domain objects
# for it. Return an array of 2-element array refs.
sub find_vm2_server
{
local ($user, $pass) = @_;
local @rv;
foreach my $s (&server_manager::list_managed_servers()) {
	local @doms = &server_manager::get_server_domains($s);
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

1;

