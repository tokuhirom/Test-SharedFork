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

plan tests => 3;

ok(1, 'one');
if (!Test::SharedFork::fork) {
    ok(1, 'two');
    exit 0;
}
1 while wait == -1;
ok(1, 'three');

