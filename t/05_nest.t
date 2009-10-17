use strict;
use warnings;
use Test::More tests => 4;
use Test::SharedFork;

&main;exit 0;

sub main {
    my $pid = Test::SharedFork->fork();
    if ($pid>0) {
        ok 1;

        my $pid = Test::SharedFork->fork();
        if ($pid>0) {
            ok 1;
            return;
        } elsif ($pid==0) {
            ok 1;
            return;
        } else {
            die $!;
        }
    } elsif ($pid==0) {
        ok 1;
        return;
    } else {
        die $!;
    }
}
