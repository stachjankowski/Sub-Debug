use strict;
use warnings;

use Test::More;
use Sub::Debug;

my $vars = { '$x' => 5, '$y' => 6, '@y' => 7, '$z' => 8 };
Sub::Debug::_filter_variables( 'include', $vars, qw/ $x $y / );
is_deeply( $vars, { '$x' => 5, '$y' => 6 } );

$vars = { '$x' => 5, '$y' => 6, '@y' => 7, '$z' => 8 };
Sub::Debug::_filter_variables( 'exclude', $vars, qw/ $x $y / );
is_deeply( $vars, { '@y' => 7, '$z' => 8 } );

done_testing();
