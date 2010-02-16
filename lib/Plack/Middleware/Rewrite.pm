package Plack::Middleware::Rewrite;

use warnings;
use strict;

use parent 'Plack::Middleware';

sub call {
    my ($self, $env) = @_;

    my $table = $self->{table};

    for (my $i = 0; $i < @$table; $i += 2) {
        (my $subst = $table->[$i+1]) =~ s/\|/\\\|/g;
        my $flags = ($subst =~ s/\s+\[(\w+)\]$//) ? $1 : '';

        if ($env->{REQUEST_URI} =~ s{$table->[$i]}{eval "qq|$subst|"}e) {
            if ($flags =~ /R/) {
                return [304, [Location => $env->{REQUEST_URI}], []];
            }
            $env->{PATH_INFO} = $env->{REQUEST_URI};
        }
    }

    return $self->app->($env);
}

=head1 NAME

Plack::Middleware::Rewrite - URL-rewriting engine

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

This is a middleware to be used in development of PSGI web
applications.

    # in your app.psgi
    use Plack::Builder;

    builder {
        enable "Plack::Middleware::Rewrite", table => [
            qr{^/index\.php$}   => '/ [R]',     # external redirect
            qr{^/(.+)\.html$}   => '/page/$1',  # simple rewrite
        ];
        $app;
    }

=head1 REWRITE TABLE FORMAT

=head2 Simple rewrites

=head2 Redirects

=head1 AUTHOR

Alex Kapranoff, C<< <kappa at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-plack-middleware-rewrite at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Plack-Middleware-Rewrite>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Plack::Middleware::Rewrite

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Plack-Middleware-Rewrite>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Plack-Middleware-Rewrite>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Plack-Middleware-Rewrite>

=item * Search CPAN

L<http://search.cpan.org/dist/Plack-Middleware-Rewrite/>

=back

=head1 ACKNOWLEDGEMENTS

=head1 LICENSE AND COPYRIGHT

Copyright 2010 Alex Kapranoff.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut

1; # End of Plack::Middleware::Rewrite
