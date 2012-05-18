package WWW::INFOnline::Report::Summary::Result;

use Moose;
use namespace::autoclean;

=head1 NAME

WWW::INFOnline::Report::Summary::Result - Result class for Summary report

=head1 ATTRIBUTES

=head2 total_impressions

Total number of page impressions

=head2 total_visits

Total number of visits

=head2 average_impressions

Average number of page impressions

=head2 average_visits

Average number of visits

=head2 average_ratio

Average page impressions/visit ratio

=head2 cookie_acceptance

HashRef of absolute and relative cookie acceptance data.

  for my $accept( qw/ 0..1 / ) {
    say sprintf( "%s / %s", 
        $report->cookie_acceptance->{ $accept }->{ 'absolute' },
        $report->cookie_acceptance->{ $accept }->{ 'percentage' }
    );
  }

=head2 sections 

HashRef of sections and their respective page impressions

=cut

has total_impressions   => ( is => 'ro', isa => 'Int', required => 1 );
has total_visits        => ( is => 'ro', isa => 'Int', required => 1 );
has average_impressions => ( is => 'ro', isa => 'Num', required => 1 );
has average_visits      => ( is => 'ro', isa => 'Num', required => 1 );
has average_ratio       => ( is => 'ro', isa => 'Num', required => 1 );
has cookie_acceptance   => ( is => 'ro', isa => 'HashRef', required => 1 );
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
