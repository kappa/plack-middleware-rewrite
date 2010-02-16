#! /usr/bin/perl
use strict;
use warnings;
use Test::More;
#use Test::NoWarnings;
use HTTP::Request::Common;
use Plack::Test;
use Plack::Builder;

sub test_rewrite {
    my ($rw, $req, $re) = @_;

    my $app = builder {
        enable "Plack::Middleware::Rewrite", table => $rw;
        sub { [ 200, [ 'Content-Type' => 'text/plain' ],
                     [ $_[0]->{REQUEST_URI} ] ] };
    };
    test_psgi app => $app, client => sub {
        my $res = $_[0]->($req);
        is $res->code, 200;
        is $res->content, $re;
    };
}

sub test_redirect {
    my ($rw, $req, $loc) = @_;

    my $app = builder {
        enable "Plack::Middleware::Rewrite", table => $rw;
        sub { [ 200, [ 'Content-Type' => 'text/plain' ],
                     [ $_[0]->{REQUEST_URI} ] ] };
    };
    test_psgi app => $app, client => sub {
        my $res = $_[0]->($req);
        is $res->code, 304;
        is $res->header('Location'), $loc;
    };
}

my $rw = [
    qr{^/$}             => '/cgi/Portal',
    qr{^/wish(/?.*)$}   => '/cgi/AddWish$1',
    qr(^/%7B$)          => '/[',
    qr(^/%7D$)          => '/]|"',
    qr{^/(.+)\.html$}   => '/Page/$1',
    qr{^/([a-z0-9-]+)/([0-9]+)/?$} => '/Club/entry/$2?nick=$1',
    qr{^/lenta$}        => '/club [R]',
];

test_rewrite($rw, GET('/vasya'), '/vasya');
test_rewrite($rw, GET('/'), '/cgi/Portal');
test_rewrite($rw, GET('/wish'), '/cgi/AddWish');
test_rewrite($rw, GET('/wish1'), '/cgi/AddWish1');
test_rewrite($rw, GET('/wish/1'), '/cgi/AddWish/1');
test_rewrite($rw, GET('/{'), '/[');
test_rewrite($rw, GET('/%7B'), '/[');
test_rewrite($rw, GET('/}'), '/]|"');
test_rewrite($rw, GET('/vasya.html'), '/Page/vasya');
test_rewrite($rw, GET('/vasya/32'), '/Club/entry/32?nick=vasya');

test_redirect($rw, GET('/lenta'), '/club');

# XXX permanent redirect
# XXX fall-through (non-break, non-last, C)
# 10 times loop
# Если в строке замены указаны аргументы, то предыдущие аргументы запроса добавляются после них. Можно отказаться от этого добавления, указав в конце строки замены знак вопроса:

done_testing;
