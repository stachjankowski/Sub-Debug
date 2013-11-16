use strict;
use warnings;

use Test::More;
use Test::Exception;

my $buffer;
use Sub::Debug sub { $buffer .= shift };

my $error = "my test died";
my $expected_error;
sub test : Debug {
    # poniżej ważne jest aby __FILE__, __LINE__ i die były w jednej linii
    # $expected_error powinien mieć na końcu znak nowej linii ale ze względu
    # na trudność użycia wyrażeń regularnych na wieloliniowych ciągach
    # znak ten został pominięty
    $expected_error = sprintf "%s at %s line %d.", $error, __FILE__, __LINE__; die($error);
}

dies_ok { test };

ok( $buffer =~ /\'error\' \=\> \'$expected_error/ );

done_testing();