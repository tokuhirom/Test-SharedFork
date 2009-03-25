use strict;
use warnings;
use Test::More tests => 42;
use Test::SharedFork;

my $pid = fork();
if ($pid == 0) {
    # child
    Test::SharedFork->child;

    my $i = 0;
    for (1..20) {
        $i++;
        ok 1, "child $_"
    }
    is $i, 20;

    exit;
} elsif ($pid) {
    # parent
    Test::SharedFork->parent;

    my $i = 0;
    for (1..20) {
        $i++;
        ok 1, "parent $_";
    }
    is $i, 20;
    waitpid($pid, 0);

    exit;
} else {
    die $!;
}

