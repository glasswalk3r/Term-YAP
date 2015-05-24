use strict;
use warnings;
use Test::More tests => 3;
use Moose;
use Test::Moose;
use Config;

my $class = 'Term::YAP::iThread';

BEGIN {

  SKIP: {

        skip 'ithreads is not available on this perl', 1
          unless ( $Config{useithreads} );

        use_ok('Term::YAP::iThread');

    }

}

SKIP: {

    skip 'ithreads is not available on this perl', 2
      unless ( $Config{useithreads} );

    has_attribute_ok( $class, 'queue' );
    can_ok( $class, qw(get_queue BUILD) );

}
