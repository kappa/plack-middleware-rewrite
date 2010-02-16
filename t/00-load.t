#!perl -T

use Test::More tests => 1;

BEGIN {
    use_ok( 'Plack::Middleware::Rewrite' ) || print "Bail out!
";
}

diag( "Testing Plack::Middleware::Rewrite $Plack::Middleware::Rewrite::VERSION, Perl $], $^X" );
