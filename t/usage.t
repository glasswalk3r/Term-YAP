use strict;
use warnings;
use Test::More;
use Config;
use Test::Moose;
use Moose;

my $yap;
my $tests = 6;
my $sleep = 5;

my %params = (
    name      => 'testing',
    rotatable => 1,
    time      => 1
);

if ( $Config{useithreads} ) {

    $tests += 2;

}

plan tests => $tests;

SKIP: {

    skip 'Not developer machine', $tests
      unless ( ( exists( $ENV{TERMYAP_DEVEL} ) ) and ( $ENV{TERMYAP_DEVEL} ) );

    if ( $Config{useithreads} ) {

        require Term::YAP::iThread;

        ok(
            $yap = Term::YAP::iThread->new( \%params ),
            'can create a instance of Term::YAP'
        );
        has_attribute_ok( $yap, 'queue' );
        can_ok( $yap, qw(get_queue) );

    }
    else {

        require Term::YAP::Process;
        ok(
            $yap = Term::YAP::Process->new( \%params ),
            'can create a instance of Term::YAP'
        );

    }

    isa_ok( $yap, 'Term::YAP' );
    ok( $yap->start, 'start method works' );
    sleep $sleep;
    ok( $yap->stop, 'stop method works' );
    sleep $sleep;
    ok( $yap->start, 'start method works' );
    sleep $sleep;
    ok( $yap->stop, 'stop method works' );

}
