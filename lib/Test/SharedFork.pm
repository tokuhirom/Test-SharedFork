package Test::SharedFork;
use strict;
use warnings;
our $VERSION = '0.03';
use Test::Builder;
use Test::SharedFork::Scalar;
use Test::SharedFork::Array;
use Test::SharedFork::Store;
use Storable ();
use File::Temp ();
use Fcntl ':flock';

our $TEST;
my $tmpnam;
sub import {
    $TEST ||= Test::Builder->new();

    $tmpnam ||= File::Temp::tmpnam();

    my $store = Test::SharedFork::Store->new($tmpnam);
    $store->lock_cb(sub {
        $store->initialize();
    }, LOCK_EX);
    undef $store;
}

my $CLEANUPME;
sub parent {
    my $store = _setup();
    $CLEANUPME = $store;
}

sub child {
    # And musuka said: 'ラピュタは滅びぬ！何度でもよみがえるさ！'
    # (Quote from 'LAPUTA: Castle in he Sky')
    $TEST->no_ending(1);

    _setup();
}

sub _setup {
    my $store = Test::SharedFork::Store->new($tmpnam);
    tie $TEST->{Curr_Test}, 'Test::SharedFork::Scalar', 0, $store;
    tie @{$TEST->{Test_Results}}, 'Test::SharedFork::Array', $store;

    no strict 'refs';
    no warnings 'redefine';
    for my $name (qw/ok skip todo_skip current_test/) {
        my $cur = *{"Test::Builder::${name}"}{CODE};
        *{"Test::Builder::${name}"} = sub {
            my @args = @_;
            $store->lock_cb(sub {
                $cur->(@args);
            });
        };
    };
    return $store;
}

sub fork {
    my $self = shift;

    my $pid = fork();
    if ($pid == 0) {
        child();
        return $pid;
    } elsif ($pid > 0) {
        parent();
        return $pid;
    } else {
        return $pid; # error
    }
}

END {
    if ($CLEANUPME) {
        unlink $tmpnam;
    }
}

1;
__END__

=head1 NAME

Test::SharedFork - fork test

=head1 SYNOPSIS

    use Test::More tests => 200;
    use Test::SharedFork;

    my $pid = fork();
    if ($pid == 0) {
        # child
        Test::SharedFork->child;
        ok 1, "child $_" for 1..100;
    } elsif ($pid) {
        # parent
        Test::SharedFork->parent;
        ok 1, "parent $_" for 1..100;
        waitpid($pid, 0);
    } else {
        die $!;
    }

=head1 DESCRIPTION

Test::SharedFork is utility module for Test::Builder.
This module makes forking test!

This module merges test count with parent process & child process.

=head1 METHODS

=over 4

=item parent

call this class method, if you are parent

=item child

call this class method, if you are child.

you can call this method many times(maybe the number of your children).

=item fork

This method calls fork(2), and call child() or parent() automatically.
Return value is pass through from fork(2).

=back

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom  slkjfd gmail.comE<gt>

yappo

=head1 SEE ALSO

L<Test::TCP>, L<Test::Fork>, L<Test::MultipleFork>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
