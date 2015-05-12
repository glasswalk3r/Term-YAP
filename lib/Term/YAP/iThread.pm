package Term::YAP::iThread;

use strict;
use warnings;
use Moo;
use threads;
use Thread::Queue;
use Types::Standard qw(InstanceOf);

extends 'Term::YAP';

#use namespace::autoclean;

=head1 NAME

Term::YAP::iThread - subclass of Term::YAP implemented with ithreads

=cut

=head1 SYNOPSIS

See parent class.

=head1 DESCRIPTION

Subclass of L<Term::YAP> implemented with ithreads. The pun with it's name is intended.

Despite the limitation of L<http://perldoc.perl.org/threads.html#WARNING|'ithreads'> some platforms (like Microsoft Windows) does not work well
with process handling of Perl. If you in this case, this implementation of L<Term::YAP> might help you.

If you program code does not handle C<ithreads> correctly, consider initiation a Term::YAP::iThread object in a C<BEGIN> block to avoid loading
the code that does not support C<ithreads>.

=head1 ATTRIBUTES

Additionally to all attributes from superclass, this class also has the C<queue> attribute.

=head2 queue

Keeps a reference of a L<Thread::Queue> instance. This instance is created automatically during L<Term::YAP::iThread> creation.

=cut

has queue => (
    is      => 'rw',
    isa     => InstanceOf ['Thread::Queue'],
    reader  => 'get_queue',
    builder => sub { Thread::Queue->new() }
);

=head1 METHODS

The following methods are overriden from parent class:

=over

=item start

=item stop

=back

=head2 get_queue

Getter for the C<queue> attribute.

=head2 BUILD

Creates a thread right after object instantiation.

The thread will start only after C<start> method is called. 

=cut

sub BUILD {

    my $self = shift;
    my $thread = threads->create( sub { $self->_keep_pulsing() } );

}

around start => sub {

    my ( $orig, $self ) = ( shift, shift );
    $self->get_queue()->enqueue(1);
    return 1;

};

around _keep_pulsing => sub {

    my ( $orig, $self ) = ( shift, shift );

    my $start = $self->get_queue()->dequeue();

    $self->$orig(@_);

};

around _is_enough => sub {

    my ( $orig, $self ) = ( shift, shift );
    return $self->get_queue()->dequeue_nb();

};

around stop => sub {

    my ( $orig, $self ) = ( shift, shift );

    my @list = threads->list(threads::running);

    foreach my $child (@list) {

        $self->get_queue()->enqueue(1);
        $child->join;

    }

    $self->$orig;

};

=head1 SEE ALSO

=over

=item *

L<Term::Pulse>

=item *

L<Moo>

=item *

L<Term::YAP::Pulse>

=back

=head1 AUTHOR

Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

L<Term::Pulse> was originally created by Yen-Liang Chen, E<lt>alec at cpan.comE<gt>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2015 of Alceu Rodrigues de Freitas Junior, E<lt>arfreitas@cpan.orgE<gt>

This file is part of Term-YAP distribution.

Term-YAP is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Term-YAP is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Term-YAP. If not, see <http://www.gnu.org/licenses/>.

=cut

1;
