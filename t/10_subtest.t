use strict;
use warnings;
use utf8;
use Test::More tests => 1;
use Test::Requires {'Test::More' => 0.96};
use App::Prove;

my $prove = App::Prove->new();
$prove->process_args('-Ilib', 't/nest/subtest.ttt');

close STDERR;  # don't allow prove to display expected failure diagnostics
ok(!$prove->run(), 'this test should fail');
