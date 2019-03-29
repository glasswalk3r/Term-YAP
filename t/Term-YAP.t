use strict;
use warnings;
use Test::More;
use Moose 2.1604;
use Test::Moose 2.1604;
use Term::YAP;
use Test::Exception 0.43;
use Test::TempDir::Tiny 0.018;
use File::Spec;

my @attributes = qw(size start_time usleep name rotatable time running output _is_output_stdout);

plan tests => scalar(@attributes) + 15;

foreach my $attrib (@attributes) {
    has_attribute_ok( 'Term::YAP', $attrib );
}

can_ok(
    'Term::YAP',
    (
        'get_size', '_set_start', '_get_usleep',   'BUILD',
        'start',    '_is_enough', '_keep_pulsing', 'stop',
        '_report',  'is_running', '_set_running',  'to_output',
    )
);

my $dir = tempdir();
my $t   = Term::YAP->new(
    { output => File::Temp->new( DIR => $dir, SUFFIX => '.txt', UNLINK => 0 ) }
);
dies_ok { $t->_is_enough } '_is_enough() requires overriding';
like(
    $@,
    qr/method must be overrided by subclasses/m,
    'got expected error message'
);

test_instance( 'Testing now with default parameters', $dir );
test_instance( 'Testing now with rotatable = 1', $dir, { rotatable => 1 } );
test_instance( 'Testing now with time = 1', $dir, { time => 1 } );

sub test_instance {
    my ( $test_name, $dir, $attribs_ref ) = @_;
    my $output = File::Temp->new( DIR => $dir, SUFFIX => '.txt', UNLINK => 0 );
    $attribs_ref->{output} = $output;
    note($test_name);
    my $t = Term::YAP->new($attribs_ref);
    ok( $t,           'have a proper instance' );
    ok( !$t->start(), 'returns false when invoking start()' );
    ok( $t->stop() );

    # explicit close to force flush on the file handle
    #$output->close();
    my $data;

    {
        local $/;
        my $filename = $attribs_ref->{output}->filename();
        open( my $fh, '<', $filename ) or die "Cannot read $filename: $!";
        $data = <$fh>;
        close($fh);
    }
    like( $data, qr/Working.................Done/m, 'report is the same' )
      or diag( explain($data) );

    return $t;
}
