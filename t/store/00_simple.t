use strict;
use warnings;
use Test::More;
use Test::SharedFork::Store;

my $s = Test::SharedFork::Store->new(cb => sub { });
$s->set(foo => 'bar');
is $s->get('foo'), 'bar';

done_testing;
