use strict;
use warnings;
use Test::SharedFork::Store;
use Test::SharedFork::Scalar;
use Test::More;

my $store = Test::SharedFork::Store->new();
tie my $x, 'Test::SharedFork::Scalar', 0, $store;
$x = 3;
is $x, 3;

done_testing;

