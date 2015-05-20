use strict;
use warnings;
use Test::More tests => 3;
use Moose;
use Test::Moose;

my $class = 'Term::YAP::iThread';

BEGIN { use_ok('Term::YAP::iThread') };
has_attribute_ok($class,'queue');
can_ok($class, qw(get_queue BUILD));