use strict;
use warnings;

use Test::More tests => 1;
use Test::Builder::Tester;
use Test::SharedFork;

test_out 'not ok 1';
test_fail +3;
test_err "#          got: '0'";
test_err "#     expected: '1'";
is 0, 1;
test_test 'Failure locations should be correct';
