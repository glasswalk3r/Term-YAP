use strict;
use warnings;
use Config;

my $yap;

my %params = ( name   => 'testing',
				rotatable => 1,
				time => 1 );

if ($Config{useithreads}) {

	require Term::YAP::iThread;
	$yap = Term::YAP::iThread->new( \%params );
	
} else {

	require require Term::YAP::Process;
	$yap = Term::YAP::Process->new( \%params );
	
}

$yap->start;
sleep 5;
$yap->stop;
