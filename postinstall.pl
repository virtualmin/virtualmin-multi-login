
require 'virtualmin-multi-login-lib.pl';

sub module_install
{
# Make this module available anonymously
local %miniserv;
&get_miniserv_config(\%miniserv);
local @anon = split(/\s+/, $miniserv{'anonymous'});
local $found = 0;
foreach my $a (@anon) {
	local ($path, $user) = split(/=/, $a);
	$found++ if ($path eq "/$module_name");
	}
if (!$found) {
	local %acl;
	&read_acl(undef, \%acl);
	local $defuser = $acl{'root'} ? 'root' :
			 $acl{'admin'} ? 'admin' :
			 (keys %acl)[0];
	push(@anon, "/$module_name=$defuser");
	$miniserv{'anonymous'} = join(" ", @anon);
	&put_miniserv_config(\%miniserv);
	&reload_miniserv();
	}
}

