package Test::SharedFork::Store;
use strict;
use warnings;
use Storable ();
use Fcntl ':seek', ':DEFAULT', ':flock';

sub new {
    my ($class, $tmpnam) = @_;
    sysopen my $fh, $tmpnam, O_RDWR|O_CREAT or die $!;
    bless {fh => $fh, lock => 0}, $class;
}

sub initialize {
    my $self = shift;

    truncate $self->{fh}, 0;
    seek $self->{fh}, 0, SEEK_SET;
    Storable::nstore_fd(+{
        array => [],
        scalar => 0,
    }, $self->{fh});
}

sub share { shift->{share} }

sub get {
    my ($self, $key) = @_;

    my $ret = $self->lock_cb(sub {
        $self->get_nolock($key);
    }, LOCK_SH);
    return $ret;
}

sub get_nolock {
    my ($self, $key) = @_;
    sysseek $self->{fh}, 0, SEEK_SET or die $!;
    Storable::fd_retrieve($self->{fh})->{$key};
}

sub set {
    my ($self, $key, $val) = @_;

    $self->lock_cb(sub {
        $self->set_nolock($key, $val);
    }, LOCK_EX);
}

sub set_nolock {
    my ($self, $key, $val) = @_;

    sysseek $self->{fh}, 0, SEEK_SET or die $!;
    my $dat = Storable::fd_retrieve($self->{fh});
    $dat->{$key} = $val;
    sysseek $self->{fh}, 0, SEEK_SET or die $!;
    Storable::nstore_fd($dat => $self->{fh});
}

sub lock {
    my $self = shift;
}

sub unlock {
    my $self = shift;
}

sub lock_cb {
    my ($self, $cb, $type) = @_;
    $type ||= LOCK_EX;

    $self->{lock}++;
    flock $self->{fh}, LOCK_EX or die $!;

    my $ret = $cb->();

    $self->{lock}--;
    if ($self->{lock} == 0) {
        flock $self->{fh}, LOCK_UN or die $!;
    }

    $ret;
}

1;
