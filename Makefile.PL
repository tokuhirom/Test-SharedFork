use inc::Module::Install;
name 'Test-Fork';
all_from 'lib/Test/Fork.pm';

requires 'IPC::ShareLite' => 0.17;

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
