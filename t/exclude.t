use strict;
use warnings;

use Test::More;
my $buffer;
use Sub::Debug sub { $buffer .= shift };

sub test : Debug(exclude=>[qw/$x $z/]) {
    my ( $x, %y ) = @_;
    my $z = $x;
}

test();

ok( $buffer !~ /\$x/ );
ok( $buffer !~ /\$z/ );
ok( $buffer =~ /\%y/ );

done_testing();