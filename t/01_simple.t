use strict;
use warnings;
use Config;
use Test::More;
use Test::SharedFork;
use Time::HiRes qw/sleep/;

plan skip_all => "fork not supported on this platform"
  unless $Config::Config{d_fork} || $Config::Config{d_pseudofork} ||
    (($^O eq 'MSWin32' || $^O eq 'NetWare') and
     $Config::Config{useithreads} and
     $Config::Config{ccflags} =~ /-DPERL_IMPLICIT_SYS/);

plan tests => 43;

my $pid = fork();
if ($pid == 0) {
    # child
    Test::SharedFork->child;

    my $i = 0;
    for (1..20) {
        $i++;
        ok 1, "child $_";
        sleep(1);
    }
    is $i, 20, 'child finished';

    1 while wait() != -1;
    exit;
} elsif ($pid) {
    # parent
    Test::SharedFork->parent;

    my $i = 0;
    for (1..20) {
        $i++;
        ok 1, "parent $_";
        sleep(1);
    }
    is $i, 20, 'parent finished';
    waitpid($pid, 0);

    ok 1, 'wait ok';

    exit;
} else {
    die $!;
}

