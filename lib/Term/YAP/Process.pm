package Term::YAP::Process;

use strict;
use warnings;
use Moo;
use Types::Standard qw(Int Bool);
use Config;
use Carp qw(confess);
use Time::HiRes qw(usleep);

extends 'Term::YAP';

=head1 NAME

Term::YAP::Process - process based subclass of Term::YAP

=cut

=head1 SYNOPSIS

See parent class.

=head1 DESCRIPTION

This module is a C<fork> base implementation of L<Term::YAP>.

=head1 ATTRIBUTES

All from parent class plus the described below.

=head2 child_pid

The PID from the child process created to start the pulse.

This is a read-only attribute and it's value is set after invoking the C<start> method.

=cut

has child_pid => (
    is     => 'ro',
    isa    => Int,
    reader => 'get_child_pid',
    writer => '_set_child_pid'
);

=head2 usr1

This class uses a USR1 signal to stop the child process of printing the pulse bar.

This read-only attribute holds the signal number (an integer) that is built during class instantiation depending
on the platform where is executed.

=cut

has usr1 => (
    is      => 'ro',
    isa     => Int,
    reader  => 'get_usr1',
    writer  => '_set_usr1',
    builder => \&_define_signal
);

=head2 enough

This read-only attribute is a boolean used by the child process to check if it should stop printing the pulse bar.

You probably won't need to use externally this attribute.

=cut

has enough => (
    is      => 'ro',
    isa     => Bool,
    default => 0,
    reader  => 'is_enough',
    writer  => '_set_enough'
);

=head1 METHODS

Some parent methods are overriden:

=over

=item * 

start

=item *

stop

=back

And some others are implemented by this class.

=head2 is_enough

Getter for C<enough> attribute.

=head2 get_usr1

Returns the value of C<usr1> attribute.

=head2 get_child_pid

Returns the value of the C<child_pid> attribute.

=head2 start

Method overrided from parent class.

This method will use C<fork> to create a child process to create the pulse bar.

The child process will have a signal handler for the USR1 signal to stop the pulse bar.

=cut

around start => sub {

    my ( $orig, $self ) = ( shift, shift );

    my $child_pid = fork();

    if ($child_pid) {

        #parent
        $self->_set_child_pid($child_pid);

    }
    else {
        #child
        $SIG{USR1} = sub { $self->_set_enough(1) };
        $self->_keep_pulsing();
        exit 0;

    }

};

sub _define_signal {

    my %sig_num;
    unless ( $Config{sig_name} && $Config{sig_num} ) {
        confess "No sigs?";
    }
    else {
        my @names = split ' ', $Config{sig_name};
        @sig_num{@names} = split ' ', $Config{sig_num};

        confess("this platform does not include USR1 signal")
          unless ( exists( $sig_num{USR1} ) );

        return $sig_num{USR1};

    }

}

=head2 stop

Method overrided from parent class.

This method will send a USR1 signal with C<kill> to the child process executing the
pulse bar.

The child process termination will be handled with C<waitpid>.

=cut

around stop => sub {

    my ( $orig, $self ) = ( shift, shift );

    kill $self->get_usr1(), $self->get_child_pid();
    usleep(250000);
    waitpid( $self->get_child_pid(), 0 );

    $self->$orig();

};

around _is_enough => sub {

    my ( $orig, $self ) = ( shift, shift );
    return $self->is_enough();

};

=head1 SEE ALSO

=over

=item *

L<Term::Pulse>

=item *

L<Term::YAP::iThread>

=item *

L<Moo>

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

L<Term::Pulse> was originally created by Yen-Liang Chen, E<lt>alec at cpan.comE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2012 of Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

This file is part of Siebel Monitoring Tools.

Siebel Monitoring Tools is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Siebel Monitoring Tools is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Siebel Monitoring Tools.  If not, see <http://www.gnu.org/licenses/>.

=cut

1;
