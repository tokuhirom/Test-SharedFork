use strict;
use warnings;
use Config;
use Test::More;
use Test::SharedFork;

plan skip_all => "fork not supported on this platform"
  unless $Config::Config{d_fork} || $Config::Config{d_pseudofork} ||
    (($^O eq 'MSWin32' || $^O eq 'NetWare') and
     $Config::Config{useithreads} and
     $Config::Config{ccflags} =~ /-DPERL_IMPLICIT_SYS/);

plan tests => 43;

my $pid = Test::SharedFork->fork();
if ($pid == 0) {
    # child
    my $i = 0;
    for (1..20) {
        $i++;
        ok 1, "child $_";
        sleep(1);
    }
    is $i, 20, 'child finished';

    exit;
} elsif ($pid) {
    # parent
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

