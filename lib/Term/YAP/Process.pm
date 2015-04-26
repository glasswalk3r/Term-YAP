package Term::YAP;

use 5.010000;
use strict;
use warnings;

=head1 NAME

Term::YAP - show pulsed progress bar in terminal

=cut

use Time::HiRes qw(usleep time);

=head1 SYNOPSIS

    use Siebel::Srvrmgr::Exporter::TermPulse;
    pulse_start( name => 'Checking', rotate => 0, time => 1 ); # start the pulse
    sleep 3;
    pulse_stop()                                               # stop it

=head1 DESCRIPTION

This module was shamelessly copied from L<Term::Pulse>. Sorry, couldn't get my bug/patch approved. :-)

=head1 EXPORT

The following functions are exported by default.

=over

=item * 

pulse_start

=item *

pulse_stop

=back

=head1 FUNCTIONS

=head2 pulse_start()

Use this functions to start the pulse. Accept the following arguments:

=over

=item name

A simple message displayed before the pulse. The default value is 'Working'.

=item rotate

Boolean. Rotate the pulse if set to 1. Turn off by default.

=item time

Boolean. Display the elapsed time if set to 1. Turn off by default.

=item size

Set the pulse size. The default value is 16.

=back

=cut

my $global_name : shared = undef;
my $global_start_time : shared = 0;
my @mark = qw(- \ | / - \ | /);
$| = 1;

my $is_enough : shared = 0;

sub init_thread {
	
	my $queue = Thread::Queue->new();
	my $child = threads->create( \&rock_n_roll, $queue );
	return $queue;

}

sub pulse_start {

    my $args_ref = shift;
    my $name   = defined($args_ref->{name}) ? $args_ref->{name} : 'Working';
    my $rotate = defined($args_ref->{rotate}) ? $args_ref->{rotate} : 0;
    my $size   = defined($args_ref->{size}) ? $args_ref->{size} : 16;
    my $time   = defined($args_ref->{time}) ? $args_ref->{time} : 0;

	$args_ref->{queue}->enqueue($name);
	$args_ref->{queue}->enqueue($rotate);
	$args_ref->{queue}->enqueue($size);
	$args_ref->{queue}->enqueue($time);

}

sub rock_n_roll {

	my $queue = shift;

    my $name   = $queue->dequeue;
    my $rotate = $queue->dequeue;
    my $size   = $queue->dequeue;
    my $time   = $queue->dequeue;
	
    my $start  = time();

    $global_start_time = $start;
    $global_name       = $name;
	
	while (1) {

		last if ($is_enough);
	
		# forward
		foreach my $index ( 1 .. $size ) {
		
			last if ($is_enough);
			my $mark = $rotate ? $mark[ $index % 8 ] : q{=};
			printf "$name...[%s%s%s]", q{ } x ( $index - 1 ), $mark,
			  q{ } x ( $size - $index );
			printf " (%f sec elapsed)", ( time - $start ) if $time;
			printf "\r";
			usleep 200000;
		}

		# backward
		foreach my $index ( 1 .. $size ) {
		
			last if ($is_enough);
			my $mark = $rotate ? $mark[ ( $index % 8 ) * -1 ] : q{=};
			printf "$name...[%s%s%s]", q{ } x ( $size - $index ), $mark,
			  q{ } x ( $index - 1 );
			printf " (%f sec elapsed)", ( time - $start ) if $time;
			printf "\r";
			usleep 200000;
		
		}
		
		last if ($is_enough);
		
	}

}

=head2 pulse_stop()

Stop the pulse and return elapsed time.

=cut

sub pulse_stop {

    my @list = threads->list(threads::running);
	
	foreach my $child(@list) {
	
		print 'stopping thread ', $child->tid, "\n";
	
		$is_enough = 1;
		$child->join;
	
	}
	
	my $length = length($global_name);
	printf "$global_name%sDone%s\n", q{.} x ( 35 - $length ), q{ } x 43;

	my $elapsed_time = time - $global_start_time;
	
	print 'Remaining: ', scalar(threads->list), "\n";
	
	return $elapsed_time;	

}

=head1 SEE ALSO

=over

=item *

L<Term::Pulse>

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
