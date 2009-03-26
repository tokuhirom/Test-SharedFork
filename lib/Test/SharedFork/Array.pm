package Test::SharedFork::Array;
use strict;
use warnings;
use base 'Tie::Array';
use Storable ();

sub _get {
    my $self = shift;

    return $self->{share}->lock_cb(sub {
        $self->{share}->get('array');
    });
}
sub FETCH {
    my ($self, $index) = @_;
    $self->_get()->[$index];
}
sub FETCHSIZE {
    my $self = shift;
    my $ary = $self->_get();
    scalar @$ary;
}

sub TIEARRAY {
    my ($class, $share) = @_;
    my $self = bless { share => $share }, $class;
    $self;
}

sub STORE {
    my ($self, $index, $val) = @_;

    $self->{share}->lock_cb(sub {
        my $share = $self->{share};
        my $cur = $share->get('array');
        $cur->[$index] = $val;
        $share->set(array => $cur);
    });
}

1;
