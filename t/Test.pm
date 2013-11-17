package t::Test;

use t::Log;
use Sub::Debug \&t::Log::Log;

sub test : Debug {
    my ($x, $y) = @_;
}

sub test2 : Debug(qw(-nomem)) {
    my ($x, $y) = @_;
    my $z = 6;
    $x = 7;
    return 10;
}

1;