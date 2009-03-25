package Test::SharedFork::Store;
use strict;
use warnings;
use IPC::ShareLite ':lock';
use Storable ();

sub new {
    my $class = shift;
    my $share = IPC::ShareLite->new(
        -key => 0721, ## no critic
        -create => 'yes',
        -destroy => 'no',
    ) or die $!;
    bless {share => $share, lock => 0}, $class;
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
    my $dat = $self->{share}->fetch() or die "cannot get the shared data";
    Storable::thaw($dat)->{$key};
}

sub set {
    my ($self, $key, $val) = @_;

    $self->lock_cb(sub {
        $self->set_nolock($key, $val);
    }, LOCK_EX);
}

sub set_nolock {
    my ($self, $key, $val) = @_;
    my $share = $self->{share};
    my $dat = Storable::thaw($share->fetch());
    $dat->{$key} = $val;
    $share->store(Storable::nfreeze($dat))
}

sub lock {
    my $self = shift;
    $self->{lock}++;
    $self->{share}->lock(@_);
}

sub unlock {
    my $self = shift;
    $self->{lock}--;
    if ($self->{lock} == 0) {
        $self->{share}->unlock();
    }
}

sub lock_cb {
    my ($self, $cb, $type) = @_;
    $type ||= LOCK_EX;

    $self->lock(LOCK_EX);
    my $ret = $cb->();
    $self->unlock();
    $ret;
}

1;
