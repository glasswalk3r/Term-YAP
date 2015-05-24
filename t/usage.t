use strict;
use warnings;
use Test::More;
use Config;
use Test::Moose;
use Moose;
use Capture::Tiny qw(capture);

my $yap;
my $tests = 6;
my $sleep = 3;

my %params = (
    name      => 'testing',
    rotatable => 1,
    time      => 1
);

plan tests => $tests;

if ( $Config{useithreads} ) {

    require Term::YAP::iThread;

    diag('ithreads available for current perl, using it');

    ok(
        $yap = Term::YAP::iThread->new( \%params ),
        'can create a instance of Term::YAP'
    );

}
else {

    require Term::YAP::Process;

    diag('ithreads NOT available for current perl, using process instead');

    ok(
        $yap = Term::YAP::Process->new( \%params ),
        'can create a instance of Term::YAP'
    );

}

isa_ok( $yap, 'Term::YAP' );

my ( $stdout, $stderr );

my $stop       = qr/testing\.+Done/;
my $is_running = 0;

# all those sleep() calls to make sure no output will modify TAP output

( $stdout, $stderr ) =
  capture { $is_running = $yap->start; sleep $sleep; $yap->stop; sleep $sleep };
like( $stdout, $stop, 'start/stop methods work' );
ok( $is_running, 'start() returned true' );

( $stdout, $stderr ) =
  capture { $is_running = $yap->start; sleep $sleep; $yap->stop; sleep $sleep };
like( $stdout, $stop, 'start/stop methods work' );
ok( $is_running, 'start() returned true' );
