package WWW::INFOnline::Report::Summary;

use Moose;
use namespace::autoclean;
use WWW::INFOnline::Report::Summary::Result;

with 'WWW::INFOnline::Report';

=head1 NAME

WWW::INFOnline::Report::Summary - Class for report type "Übersicht".

=cut

has '+type' => ( default => 'overview' );

=head1 METHODS

=head2 process()

Returns report as L<WWW::INFOnline::Report::Summary::Result> object.

=cut

sub process {
    my $self = shift;

    if( my @csv_data = $self->csv_data() ) {
        # Summary data
        my( $t_pi, $t_v, $avg_pi, $avg_v, $avg_piv ) = map { $_->[1] } @csv_data[0..1, 3..5];
        my $cookie_acceptance = {
            '0' => { absolute => $csv_data[8][1], percentage => $csv_data[8][2] },
            '1' => { absolute => $csv_data[9][1], percentage => $csv_data[9][2] }
        };

        # Section data
        my $sections = {};
        for( @csv_data[13..$#csv_data] ) {
            last unless $_->[0];
            $sections->{ $_->[0] } = $_->[1];
        }

        return WWW::INFOnline::Report::Summary::Result->new( 
            total_impressions   => $t_pi,
            total_visits        => $t_v,
            average_impressions => $avg_pi,
            average_visits      => $avg_v,
            average_ratio       => $avg_piv,
            cookie_acceptance   => $cookie_acceptance,
            sections            => $sections,
        );
    }
}

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=head1 AUTHOR

Tobias Kremer <tkremer@cpan.org>

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
