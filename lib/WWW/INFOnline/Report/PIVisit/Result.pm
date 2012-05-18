package WWW::INFOnline::Report::PIVisit::Result;

use Moose;
use namespace::autoclean;

=head1 NAME

WWW::INFOnline::Report::PIVisit::Result - Result class for PIVisit report

=head1 ATTRIBUTES

=head2 total_impressions

Total number of page impressions

=head2 total_visits

Total number of visits

=head2 total_ratio

Total page impressions/visit ratio

=head2 entries

ArrayRef of L<WWW::INFOnline::Report::PIVisit::Result::Entry> objects for every resolution unit (hour/day/month/etc.)

=head2 sections 

HashRef of sections and their respective page impressions

=cut

has total_impressions   => ( is => 'ro', isa => 'Int', required => 1 );
has total_visits        => ( is => 'ro', isa => 'Int', required => 1 );
has total_ratio         => ( is => 'ro', isa => 'Num', required => 1 );
has entries             => ( is => 'ro', isa => 'ArrayRef', required => 1 );
has sections            => ( is => 'ro', isa => 'HashRef', required => 1 );

=head1 AUTHOR

Tobias Kremer <tkremer@cpan.org>

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;

1;
