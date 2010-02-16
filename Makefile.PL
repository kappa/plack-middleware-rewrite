use inc::Module::Install;

name     'Plack-Middleware-Rewrite';
all_from 'lib/Plack/Middleware/Rewrite.pm';
author   q{Alex Kapranoff <kappa@cpan.org>};
license  'perl';

build_requires 'Test::More';

auto_install;

WriteAll;

