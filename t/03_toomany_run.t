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

plan tests => 30;

for (1..10) {
    my $pid = Test::SharedFork->fork();
    if ($pid == 0) {
        # child
        ok 1, "child $_";

        exit;
    } elsif (defined($pid)) {
        # parent
        ok 1, "parent $_";

        waitpid($pid, 0);

        ok 1, 'wait ok';
    } else {
        die "fork failed: $!";
    }
}

