# stub
sub readme_markdown_from { }
sub author_tests { }

use inc::Module::Install;

name 'Test-SharedFork';
all_from 'lib/Test/SharedFork.pm';

requires 'Test::More' => 0.62; # Test::More 0.62 is really needed

tests 't/*.t t/*/*.t t/*/*/*.t';
author_tests 'xt';

readme_markdown_from 'lib/Test/SharedFork.pm';
build_requires 'Test::More';
auto_include;
WriteAll;
