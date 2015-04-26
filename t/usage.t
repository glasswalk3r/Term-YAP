use strict;
use warnings;

use Test::More;
use Config;
use Test::Moose;
use Moose;

my $yap;
my $tests = 4;

my %params = ( name   => 'testing',
				rotatable => 1,
				time => 1 );

if ($Config{useithreads}) {

	require Term::YAP::iThread;

	plan tests => $tests + 2;
	
	ok( $yap = Term::YAP::iThread->new( \%params ), 'can create a instance of Term::YAP');
	has_attribute_ok( $yap, 'queue');
	can_ok($yap, qw(get_queue));
	
} else {

	plan tests => $tests;
	require require Term::YAP::Process;
	ok( $yap = Term::YAP::Process->new( \%params ), 'can create a instance of Term::YAP');
	
}

isa_ok($yap, 'Term::YAP');
ok($yap->start, 'start method works');
sleep 5;
ok($yap->stop, 'stop method works');
