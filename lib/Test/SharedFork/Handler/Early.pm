package Test::SharedFork::Handler::Early;

use Storable qw/nstore retrieve/;
use TB2::Mouse;
with "TB2::EventHandler";

use Fcntl qw/:flock :seek :DEFAULT/;
use File::Temp;
use Carp;

has filename => (
    is  => 'ro',
    isa => 'Str',
    default => sub {
        my $filename = File::Temp::tmpnam();
        nstore({}, $filename);
        return $filename;
    }
);

has fh => (
    is  => 'rw',
    isa => 'GlobRef'
);

has pid => (
    is  => 'rw',
    isa => 'Int',
    default => $$
);


# handle_event() handles anything not handled by some other method
sub handle_event  {
    my $self = shift;
    my($event, $ec) = @_;

    my $history = $self->_read_history_file;
    return unless $history;

    # use the history we read
    $ec->history($history);

    # continue processing the event
    return;
}


sub _read_history_file {
    my $self = shift;

    # If we forked since last opening the file, get a new
    # file handle.  Children share file descriptors with their
    # parent, and flock works on file descriptors.
    if( !$self->fh || ($self->pid != $$) ) {
        close $self->fh if $self->fh;
        open my $fh, '<', $self->filename or die $!;
        $self->fh($fh);
        $self->pid($$);
    }

    flock $self->fh, LOCK_EX or die $!;

    # read the history file
    my $history = retrieve($self->filename) || die "Can't retrieve";

    # ignore an empty history file
    return if ! defined $history or ! length $history;

    # ignore an empty hash
    return if ref $history eq 'HASH' and ! keys %$history;

    # error out if the history is corrupt
    die "Corrupted TB2::History" unless eval { $history->isa("TB2::History") };

    return $history;
}


 no TB2::Mouse;

1;
