use strict;
use warnings;

use Test::More;
use Test::Exception;

use Sub::Debug;

sub test : Debug {
    my @args = @_;
}

sub test2 : Debug {
    my ( $x, $y, %z ) = @_;
}

is_deeply( [ Sub::Debug::_in_names( $0, 'test' ) ], [qw/ @args /] );

is_deeply( [ Sub::Debug::_in_names( $0, 'test2' ) ], [qw/ $x $y %z /] );

dies_ok { Sub::Debug::_in_names($0) } 'no subroutine name';

done_testing();
