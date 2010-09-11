package Test::SharedFork::Scalar;
use strict;
use warnings;
use base 'Tie::Scalar';

# create new tied scalar
sub TIESCALAR {
    my ($class, $share) = @_;
    bless { share => $share }, $class;
}

sub FETCH {
    my $self = shift;
    my $lock = $self->{share}->get_lock();
    $self->{share}->get('scalar');
}

sub STORE {
    my ($self, $val) = @_;
    my $share = $self->{share};
    my $lock = $self->{share}->get_lock();
    $share->set('scalar' => $val);
}

1;
