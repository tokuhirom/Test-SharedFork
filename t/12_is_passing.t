use strict;
use warnings;
use utf8;
use Test::More;
use Test::SharedFork;

open my $fh, ">", \my $out or die $!;
my $builder = Test::Builder->create;
$builder->output($fh);
$builder->failure_output($fh);
$builder->todo_output($fh);

Test::SharedFork::_mangle_builder($builder);
my $pid = fork();
die $! if !defined $pid;
if ($pid) {
    # parent
    waitpid($pid, 0) or die $!;
    is $builder->is_passing, 0;
} else {
    # child
    $builder->is_passing(0);
    exit 0;
}
diag $out;

done_testing;
