package t::Test;

use Sub::Debug;

sub test : Debug {
    my ($x, $y) = @_;
}

sub test2 : Debug {
    my ($x, $y) = @_;
    my $z = 6;
    $x = 7;
    return 10;
}

1;