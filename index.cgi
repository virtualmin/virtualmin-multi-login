#!/usr/local/bin/perl
# Just show a login form. In practice, this page is probably never used..
use strict;
use warnings;
our (%text, %in, %config);

require './virtualmin-multi-login-lib.pl';
&popup_header($text{'index_title'});
&ReadParse();

print "<center>\n";
if ($in{'err'}) {
	print "<b><font color=#ff0000>",
	      &html_escape($in{'err'}),"</font></b><p>\n";
	}
print &ui_form_start("login.cgi", "post", $config{'target'});
print &ui_table_start($text{'index_header'}, undef, 2);

# Username or domain
print &ui_table_row($text{'index_user'},
		    &ui_textbox("user", $in{'user'}, 40));

# Password
print &ui_table_row($text{'index_pass'},
		    &ui_password("pass", undef, 40));

print &ui_table_end();
print &ui_form_end([ [ undef, $text{'index_ok'} ] ]);
print "</center>\n";

&popup_footer();
