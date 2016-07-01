use strict;
use warnings;
our $module_name;

require 'virtualmin-multi-login-lib.pl';

sub module_install
{
&foreign_require("acl", "acl-lib.pl");
&acl::setup_anonymous_access("/$module_name", $module_name);
}
