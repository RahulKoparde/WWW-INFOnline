package WWW::INFOnline;

our $VERSION = '0.01';

use 5.008;
use Moose;
use Carp;
use LWP::UserAgent;
use UNIVERSAL::require;
use namespace::autoclean;

$WWW::INFOnline::DEBUG = 0;

=head1 NAME

WWW::INFOnline - Object-oriented interface to INFOnline's Website Controlling Cockpit (WCC).

=head1 SYNOPSIS

  use WWW::INFOnline;

  my $api = WWW::INFOnline->new(
    username    => 'your_username',
    password    => 'your_password',
  );

  my $result = $api->report(   
    'PIVisit',
    site        => 'my_site',
    date_start  => DateTime->now()->day(1),
    date_end    => DateTime->now(), 
  );

  say $result->total_impressions();
  my @entries = @{ $results->entries() };

=head1 DESCRIPTION

This module lets you fetch reports from the IVW / INFOnline Website-Controlling-Cockpit (WCC) located at L<https://wcc.infonline.de/>.
At the moment, only parsing of the PI/Visit and summary reports is implemented, because these are the most interesting ones for me. 
Reports are just classes consuming the L<WWW::INFOnline::Report> role, thus it should be easy to add other available reports.

B<IMPORTANT NOTICE: Due to the fact that this module basically scrapes data off the web, because INFOnline does not provide 
an official API, it's entirely possible and likely that it will stop functioning correctly if the CSV data format or WCC website 
changes. I'll do my best to keep it up-to-date. Also consider the API of this module as alpha and not necessarily stable.>

=cut

has username => ( 
    isa         => 'Str', 
    is          => 'ro', 
    required    => 1 
);

has password => (
    isa         => 'Str', 
    is          => 'ro', 
    required    => 1 
);

has ua_args => (
    isa         => 'HashRef',
    is          => 'ro',
    default     => sub { {} },
);

has wcc_url => (
    isa         => 'Str',
    is          => 'ro',
    default     => 'https://wcc.infonline.de'
);

has wcc_auth_url => (
    isa         => 'Str',
    is          => 'ro',
    lazy        => 1,
    default     => sub {
        shift->wcc_url . '/j_security_check';
    }
);

has wcc_csv_url => (
    isa         => 'Str',
    is          => 'ro',
    lazy        => 1,
    default     => sub {
        shift->wcc_url . '/insitevue.csv';
    }
);

has debug => (
    isa         => 'Bool',
    is          => 'rw',
    default     => 0,
);

=head1 CONSTRUCTOR

=head2 new( %params )

  my $api = WWW::INFOnline->new(
    username    => 'your_username',
    password    => 'your_password',
  );

Creates a new WWW::INFOnline instance.

C<username> and C<password> are mandatory. These are the credentials you enter to gain access to the Website Controlling Cockpit.

If you want to pass additional parameters to L<LWP::UserAgent> which is used internally, you may do so with the C<ua_args> parameter:

  my $api = WWW::INFOnline->new(
    username    => 'your_username',
    password    => 'your_password',
    ua_args     => { agent => 'Mozilla' },
  );

NOTE: If you are behind a proxy, you might need to set the C<HTTPS_PROXY> environment variable.

If one or more URLs of the WCC change, you may override the defaults by passing in a couple of parameters:

  my $api = WWW::INFOnline->new(
    username        => 'your_username',
    password        => 'your_password',
    wcc_url         => 'https://new.infonline.de',                    # base URL
    wcc_auth_url    => 'https://new.infonline.de/j_security_check',   # authentication URL
    wcc_csv_url     => 'https://new.infonline.de/insitevue.csv'       # CSV export URL
  );

=cut

=head1 METHODS

=head2 report( $type, %params )

  my $result = $api->report( 
    'PIVisit', 
    site        => 'my_site',
    date_start  => DateTime->now()->day(1),
    date_end    => DateTime->now(),
    resolution  => 'weeks',
  );

Processes and returns the results of report C<$type> which must be the name of a L<WWW::INFOnline::Report> class (e.g. 'PIVisit' to use L<WWW::INFOnline::Report::PIVisit>). 
If you want to instantiate a homegrown report class not in the WWW::INFOnline::Report namespace, you can use a '+'-sign in front of $type (e.g. '+My::Own::Report').
Result depends on the report type. See the corresponding report class for documentation.

C<%params> is passed on to the report class's constructor, see L<WWW::INFOnline::Report/"ATTRIBUTES"> for a list of required and optional parameters that are common for all types of reports.

=cut

sub report {
    my $self = shift;
    my $class = shift;
    $class = "WWW::INFOnline::Report::$class" unless $class =~ /^\+/;
    $class =~ s/^\+//;
    $class->require() or croak "Couldn't require report class '$class': $@";
    return $class->new( api => $self, @_ )->process();
}

=head2 query( $query )

Authenticates the user and runs C<$query> parameters against the WCC returning a L<HTTP::Response> object on success. 
You'll probably never call this method directly if you aren't writing your own report classes.

=cut

sub query {
    my $self = shift;
    my $query = shift;
    my $ua = $self->_authenticate;
    my $uri = $self->wcc_csv_url . '?' . $query;
    print "$uri\n" if $WWW::INFOnline::DEBUG;
    return $ua->get( $uri ); 
}

sub _authenticate {
    my $self = shift;

    my $ua = LWP::UserAgent->new( 
        agent                   => "WWW::INFOnline/$VERSION", 
        %{ $self->ua_args },
        cookie_jar              => {},
        requests_redirectable   => [ 'GET', 'HEAD', 'POST' ],
    );

    # Get cookie
    my $res = $ua->get( $self->wcc_url );
    croak sprintf( "Can't connect to %s (Status: %s)", $self->wcc_url, $res->status_line ) unless $res->is_success;

    # Login
    $res = $ua->post( 
        $self->wcc_auth_url,
        { 
            j_username  => $self->username, 
            j_password  => $self->password,
            Submit      => 'Login',
        },
    );
    croak sprintf( "Login failed (Status: %s)", $res->status_line ) unless $res->is_success && $res->decoded_content =~ /insitevue\.html/;

    return $ua;
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
