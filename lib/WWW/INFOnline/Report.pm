package WWW::INFOnline::Report;

use Moose::Role;
use namespace::autoclean;
use Text::CSV;
use Carp;

=head1 NAME

WWW::INFOnline::Report - Role for INFOnline report classes.

=head1 DESCRIPTION

Every INFOnline report class must implement this L<Moose> role which makes sure that the required process() method
is implemented by the report and provides a centralized CSV fetching and parsing method (L<"csv_data">). 

=cut

use constant {
    IFO_RESOLUTIONS => {
        'hours'     => 'hour',
        'days'      => 'day',
        'weeks'     => 'week',
        'months'    => 'month'
    },
    IFO_MODES => {
        'absolute'  => 'absolute',
        'relative'  => 'relative'
    },
    IFO_TIME => {
        'free'      => 'free',
    },
    IFO_DATE_FORMAT => '%d-%m-%Y_%H:%M:%S'
};

=head1 ATTRIBUTES

All attributes are required. If there's no default, you must provide a value.

=head2 api

Initialized L<WWW::INFOnline> object.

=head2 site

Name of site (aka "Angebot").

=head2 date_start

Start date of report as L<DateTime> object.

=head2 date_end

End date of report as L<DateTime> object.

=head2 type

Type of report.

=head2 mode

Mode for report. Can be either "C<absolute>" (default) or "C<relative>". 

=head2 resolution

Resolution for report. Can be one of: "C<days>" (default), "C<months>", "C<weeks>", "C<hours>".

=cut

has api         => ( is => 'ro', isa => 'WWW::INFOnline', required => 1 );
has site        => ( is => 'ro', isa => 'Str', required => 1 );
has date_start  => ( is => 'ro', isa => 'DateTime', required => 1 );
has date_end    => ( is => 'ro', isa => 'DateTime', required => 1 );
has type        => ( is => 'ro', isa => 'Str', required => 1 );
has mode        => ( is => 'ro', isa => 'Str', required => 1, default => IFO_MODES->{ 'absolute' } );
has resolution  => ( is => 'ro', isa => 'Str', required => 1, default => IFO_RESOLUTIONS->{ 'days' } );

requires 'process';

=head1 ATTRIBUTES

=head2 csv_data

Queries the WCC and returns an array of CSV report data.

=cut

sub csv_data {
    my $self = shift;

    my $uri = 
        'command=page' .
        '&view=std' .
        '&reporttype='  . $self->type .
        '&site='        . $self->site .
        '&modus='       . IFO_MODES->{ $self->mode } .
        '&frequency='   . IFO_RESOLUTIONS->{ $self->resolution } .
        '&timerange='   . IFO_TIME->{ 'free' } .
        '&start='       . $self->date_start->strftime( IFO_DATE_FORMAT ) .
        '&end='         . $self->date_end->strftime( IFO_DATE_FORMAT );

    my $res = $self->api->query( $uri );

    croak sprintf( "Couldn't get CSV data (Status: %s)", $res->status_line ) unless $res->is_success;
    
    my $csv = Text::CSV->new( { binary => 1 } )
        or croak "Couldn't initialize Text::CSV: " . Text::CSV->error_diag();

    # Parse CSV data and return as array
    my @data;
    my @content = split /\n/, $res->decoded_content;
    for( @content[ 9..@content ] ) {
        $csv->parse( $_ );
        my @fields = $csv->fields();
        push @data, \@fields;
        print join( ",", @fields ) . "\n" if $self->api->debug();
    }

    croak sprintf( "No usable CSV data received." ) unless @data;

    return @data;
}

=head1 WRITING YOUR OWN REPORT

A basic skeleton for a new report class may look like this:

  package My::INFOnline::Report;

  use Moose;
  use namespace::autoclean;

  with 'WWW::INFOnline::Report';

  # reporttype is used as the "reporttype" query-parameter which indicates the type of report to produce
  has '+type' => ( default => 'reporttype' ); 

  sub process {
    if( my @csv_data = $self->csv_data() ) {
      # process @csv_data and return objects with report data
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

1;
