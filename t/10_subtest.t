use strict;
use warnings;
use utf8;
use Config;
use Test::More;
use Test::Requires {'Test::More' => 0.96};
use App::Prove;

plan skip_all => "fork not supported on this platform"
  unless $Config::Config{d_fork} || $Config::Config{d_pseudofork} ||
    (($^O eq 'MSWin32' || $^O eq 'NetWare') and
     $Config::Config{useithreads} and
     $Config::Config{ccflags} =~ /-DPERL_IMPLICIT_SYS/);

plan tests => 1;

TODO: {
    local $TODO = 'subtest is not supported yet';
    my $prove = App::Prove->new();
    $prove->process_args('--norc', '-Ilib', 't/nest/subtest.ttt');
    ok(!$prove->run(), 'this test should fail');
};


