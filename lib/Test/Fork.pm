package Test::Fork;
use strict;
use warnings;
our $VERSION = '0.01';
use Test::Builder;
use Test::Fork::Scalar;
use Test::Fork::Array;
use Test::Fork::Store;
use IPC::ShareLite ':lock';
use Storable ();

our $TEST;
sub import {
    $TEST = Test::Builder->new();

    my $store = Test::Fork::Store->new();
    $store->lock_cb(sub {
        $store->{share}->store(Storable::nfreeze(+{
            array => [],
            scalar => 0,
        }));
    }, LOCK_EX);
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
    my $store = Test::Fork::Store->new();
    tie $TEST->{Curr_Test}, 'Test::Fork::Scalar', 0, $store;
    tie @{$TEST->{Test_Results}}, 'Test::Fork::Array', $store;

    no strict 'refs';
    no warnings 'redefine';
    for my $name (qw/ok skip todo_skip current_test/) {
        my $cur = *{"Test::Builder::${name}"}{CODE};
        *{"Test::Builder::${name}"} = sub {
            my @args = @_;
            $store->lock_cb(sub {
                $cur->(@args);
            }, LOCK_EX);
        };
    };
    return $store;
}

END {
    if ($CLEANUPME) {
        $CLEANUPME->{share}->destroy(1);
    }
}

1;
__END__

=head1 NAME

Test::Fork - fork test

=head1 SYNOPSIS

    use Test::More tests => 200;
    use Test::Fork;

    my $pid = fork();
    if ($pid == 0) {
        # child
        Test::Fork->child;
        ok 1, "child $_" for 1..100;
    } elsif ($pid) {
        # parent
        Test::Fork->parent;
        ok 1, "parent $_" for 1..100;
        waitpid($pid, 0);
    } else {
        die $!;
    }

=head1 DESCRIPTION

Test::Fork is utility module for Test::Builder.
This module makes forking test!

This module merges test count with parent process & child process.

=head1 METHODS

=over 4

=item parent

call this class method, if you are parent

=item child

call this class method, if you are child.

you can call this method many times(maybe the number of your children).

=back

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom  slkjfd gmail.comE<gt>

yappo

=head1 SEE ALSO

L<Test::TCP>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
