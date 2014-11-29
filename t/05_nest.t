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

plan tests => 4;

&main;exit 0;

sub main {
    my $pid = Test::SharedFork->fork();
    if ($pid==0) {
        ok 1;
        return;
    } elsif (defined $pid) {
        ok 1;

        1 while wait() == -1;

        my $pid = Test::SharedFork->fork();
        if ($pid==0) {
            ok 1;
            return;
        } elsif (defined $pid) {
            ok 1;
            1 while wait() == -1;
            return;
        } else {
            die $!;
        }
    } else {
        die "fork failed: $!";
    }
}
