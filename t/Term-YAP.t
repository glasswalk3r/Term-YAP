use strict;
use warnings;
use Test::More tests => 5;
use Moose;
use Test::Moose;

BEGIN { use_ok('Term::YAP') };

foreach my $attrib(qw(size start usleep)) {

	has_attribute_ok('Term::YAP',$attrib);

}

can_ok('Term::YAP', qw(get_size _set_start _set_start _get_usleep BUILD start _is_enough _keep_pulsing stop _report));