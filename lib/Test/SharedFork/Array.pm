package Test::SharedFork::Array;
use strict;
use warnings;
use base 'Tie::Array';
use Storable ();

# create new tied array
sub TIEARRAY {
    my ($class, $share) = @_;
    my $self = bless { share => $share }, $class;
    $self;
}


sub _get {
    my $self = shift;
    my $lock = $self->{share}->get_lock();
    return $self->{share}->get('array');
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

sub STORE {
    my ($self, $index, $val) = @_;

    my $lock = $self->{share}->get_lock();

    my $share = $self->{share};
    my $cur = $share->get('array');
    $cur->[$index] = $val;
    $share->set(array => $cur);
}

1;
