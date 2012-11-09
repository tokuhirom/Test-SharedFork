package Test::SharedFork::Handler::Late;

use TB2::Mouse;
with "TB2::EventHandler";

use Storable qw/nstore/;
use Fcntl qw/:flock :seek/;

has early_handler => (
    is  => 'ro',
    isa => 'Test::SharedFork::Handler::Early'
);


sub subtest_handler {
    my $self = shift;
    return $self->new(
        early_handler => $self->early_handler->handler_for_subtest
    );
}

# handle_event() handles anything not handled by some other method
sub handle_event  {
    my $self = shift;
    my($event, $ec) = @_;

    # store the history
    nstore($ec->history, $self->early_handler->filename);

    # unlock
    flock $self->early_handler->fh, LOCK_UN or die $!;

    # continue processing the event
    return;
}

no TB2::Mouse;

1;
