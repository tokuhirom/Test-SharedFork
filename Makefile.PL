use inc::Module::Install;
name 'Test-SharedFork';
all_from 'lib/Test/SharedFork.pm';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
