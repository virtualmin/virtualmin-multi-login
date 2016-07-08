use Test::Strict tests => 3;                      # last test to print

syntax_ok( 'login.cgi' );
strict_ok( 'login.cgi' );
warnings_ok( 'login.cgi' );
