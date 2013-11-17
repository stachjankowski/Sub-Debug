use strict;
use warnings;

use Test::More;
use t::Test;

eval 'my %result;
use Sub::Debug \%result;
my $ret = t::Test::test2(5, 6);
is_deeply(\%result, {
    before => {
        in => { q{$x} => \5, q{$y} => \6 }
    },
    after => {
        sub    => { q{$x} => \7, q{$y} => \6, q{$z} => \6 },
        return => \10
    }
})';

done_testing();
