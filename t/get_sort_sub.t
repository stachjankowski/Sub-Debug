use strict;
use warnings;

use Test::More;
use Sub::Debug;

my $sub = Sub::Debug::_get_sort_sub(qw/$x $y %z/);
my $struct = { '$x' => undef, '$y' => undef, '%z' => undef };
is_deeply( $sub->($struct), [qw/ $x $y %z /] );

$sub = Sub::Debug::_get_sort_sub(qw/$x $y %z/);
$struct = { '$a' => undef, '$b' => undef, '%c' => undef };
is_deeply( $sub->($struct), [qw/ $a $b %c /] );

$sub = Sub::Debug::_get_sort_sub(qw/$x $y %z/);
$struct = { '%a' => undef, '%b' => undef, '$c' => undef };
is_deeply( $sub->($struct), [qw/ %a %b $c /] );

$sub = Sub::Debug::_get_sort_sub(qw/$x $y %z/);
$struct = { '$x' => undef, '%b' => undef, '$c' => undef };
is_deeply( $sub->($struct), [qw/ %b $c $x /] );

done_testing();
