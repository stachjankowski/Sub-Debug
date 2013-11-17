use strict;
use warnings;

use Test::More;
use Test::Exception;
use Sub::Debug;

is(
    Sub::Debug::_get_assignment_line( 'Sub/Debug.pm', 'UNIVERSAL::Debug' ),
    'my ( $package, $symbol, $referent, undef, $data, undef, $filename ) = @_;'
);

dies_ok { Sub::Debug::_get_assignment_line( 'Not_existing_file', 'Test' ) };

done_testing();
