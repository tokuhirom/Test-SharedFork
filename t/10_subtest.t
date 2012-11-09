use strict;
use warnings;
use utf8;
use Test::More tests => 1;
use Test::Requires {'Test::More' => 0.96};
use App::Prove;

if ($Test::More::VERSION < 1) {
    TODO: {
        local $TODO = 'subtest is not supported yet';
        my $prove = App::Prove->new();
        $prove->process_args('--norc', '-Ilib', 't/nest/subtest.ttt');
        ok(!$prove->run(), 'this test should fail');
    };
} else {
    my $prove = App::Prove->new();
    $prove->process_args('-Ilib', 't/nest/subtest.ttt');
    close STDERR;  # don't allow prove to display expected failure diagnostics
    ok(!$prove->run(), 'this test should fail');
}
