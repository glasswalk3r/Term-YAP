use 5.010000;
use ExtUtils::MakeMaker;

# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'Term::YAP',
    VERSION_FROM => 'lib/Term/YAP.pm',    # finds $VERSION
    PREREQ_PM     => { Moo => "2.000001", 'Type::Tiny' => "1.000005" },
    TEST_REQUIRES => {
        Moose         => "2.1403",
        'Test::Moose'   => "2.1403",
        'Capture::Tiny' => "0.28",
    },
    (
        $] >= 5.005
        ?    ## Add these new keywords supported since 5.005
          (
            ABSTRACT_FROM => 'lib/Term/YAP.pm',  # retrieve abstract from module
            AUTHOR => 'Alceu Rodrigues de Freitas Junior <arfreitas@cpan.org>'
          )
        : ()
    ),
);
