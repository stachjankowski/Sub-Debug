use strict;
use warnings;

use Test::More;
use Sub::Debug;


my $in_vars = Sub::Debug::_bind_in_vars(
    [qw/ $x $y %z/],
    [1, 2, key1 => 'value1', key2 => 'value2']
);
is_deeply($in_vars, {
    '$x' => \1,
    '$y' => \2,
    '%z' => {key1 => 'value1', key2 => 'value2'}
});

$in_vars = Sub::Debug::_bind_in_vars(
    [qw/ %z /],
    [key1 => 'value1', key2 => 'value2']
);
is_deeply($in_vars, {
    '%z' => {key1 => 'value1', key2 => 'value2'}
});

$in_vars = Sub::Debug::_bind_in_vars(
    [qw/ $x $y @z/],
    [1, 2, 3, 4, 5]
);
is_deeply($in_vars, {
    '$x' => \1,
    '$y' => \2,
    '@z' => [3, 4, 5]
});

$in_vars = Sub::Debug::_bind_in_vars(
    [qw//],
    [1, 2, 3, 4, 5]
);
is_deeply($in_vars, {
    '@_' => [1, 2, 3, 4, 5]
});

$in_vars = Sub::Debug::_bind_in_vars(
    [qw/ $x /],
    [1, 2, 3, 4, 5]
);
is_deeply($in_vars, {
    '$x' => \1,
    '@_' => [2, 3, 4, 5]
});

$in_vars = Sub::Debug::_bind_in_vars(
    [qw/ undef /],
    [1, 2, 3, 4, 5]
);
is_deeply($in_vars, {
    '@_' => [1, 2, 3, 4, 5]
});


done_testing();