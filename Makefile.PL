use inc::Module::Install;

# Define metadata
name            'WWW-INFOnline';
license         'perl';
all_from        'lib/WWW/INFOnline.pm';

# Specific dependencies
requires        'Moose'                 => '0.88';
requires        'namespace::autoclean'  => '0';
requires        'LWP::UserAgent'        => '0';
requires        'Carp'                  => '0';
requires        'UNIVERSAL::require'    => '0.13';
requires        'Text::CSV'             => '1.10';
requires        'DateTime'              => '0';

test_requires   'Test::More'            => '0.42';

WriteAll;
