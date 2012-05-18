#!/usr/bin/env perl

use 5.010;
use strict;
use warnings;

use WWW::INFOnline;
use DateTime;

my $api = WWW::INFOnline->new(
    username => 'your-ivw-username',
    password => 'your-ivw-password'
);

my $result = $api->report( 
    'PIVisit',  
    site        => 'your-ivw-sitename',
    mode        => 'absolute',
    resolution  => 'days', 
    date_start  => DateTime->now->set( day => 1 ),
    date_end    => DateTime->now(),
);

my @entries = $result->entries();
for my $day( @{ $result->entries() } ) {
    say sprintf( 
        "%10s %10d %10d %2.1f", 
        $day->date,
        $day->impressions, 
        $day->visits, 
        $day->ratio 
    );
}
say ("-" x 60);
say sprintf( 
    "%10s %10d %10d %2.1f", 
    "TOTAL:",   
    $result->total_impressions, 
    $result->total_visits, 
    $result->total_ratio 
);
say ("-" x 60);
