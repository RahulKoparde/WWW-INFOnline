package WWW::INFOnline::Report::PIVisit::Result::Entry;

use Moose;
use namespace::autoclean;

=head1 NAME

WWW::INFOnline::Report::Summary::Result - Result class for Summary report

=head1 ATTRIBUTES

=head2 date

Date of entry as string.

=head2 impressions

Page impressions for date.

=head2 visits

Visits for date. 

=head2 ratio

Page impressions / Visits ratio for date.

=cut

has date          => ( is => 'ro', isa => 'Str', required => 1 );
has impressions   => ( is => 'ro', isa => 'Int', required => 1 );
has visits        => ( is => 'ro', isa => 'Int', required => 1 );
has ratio         => ( is => 'ro', isa => 'Num', required => 1 );

=head1 AUTHOR

Tobias Kremer <tkremer@cpan.org>

=head1 LICENSE

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

__PACKAGE__->meta->make_immutable;
no Moose;

1;
