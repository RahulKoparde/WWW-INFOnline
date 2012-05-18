package WWW::INFOnline::Report::PIVisit;

use Moose;
use namespace::autoclean;
use WWW::INFOnline::Report::PIVisit::Result;
use WWW::INFOnline::Report::PIVisit::Result::Entry;

with 'WWW::INFOnline::Report';

=head1 NAME

WWW::INFOnline::Report::PIVisit - Class for report type "PI/Visit".

=cut

has '+type' => ( default => 'pageall' );

=head1 METHODS

=head2 process()

Returns report as L<WWW::INFOnline::Report::PIVisit::Result> object. See L<WWW::INFOnline::Report::PIVisit::Result/"ATTRIBUTES"> for result attributes.

=cut

sub process {
    my $self = shift;

    if( my @csv_data = $self->csv_data() ) {
        # PI/Visit data
        my @entries;
        my $cnt = 0;
        my( $ti, $tv, $tr ) = 0;
        for( @csv_data ) {
            my( $date, $impressions, $visits, $ratio ) = @{ $_ };
            last unless $impressions && $visits && $ratio;
            if( $date ) {
                # Individual date
                push @entries, WWW::INFOnline::Report::PIVisit::Result::Entry->new(
                    date        => $date,
                    impressions => $impressions,
                    visits      => $visits,
                    ratio       => $ratio
                );
            }
            else {
                # Totals
                $ti = $impressions;
                $tv = $visits;
                $tr = $ratio;
            }
            $cnt++;
        }

        # Section data
        my $sections = {};
        for( @csv_data[$cnt+5..$#csv_data] ) {
            last unless $_->[0];
            $sections->{ $_->[0] } = $_->[1];
        }

        return WWW::INFOnline::Report::PIVisit::Result->new( 
            total_impressions   => $ti,
            total_visits        => $tv,
            total_ratio         => $tr,
            entries             => \@entries,
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
