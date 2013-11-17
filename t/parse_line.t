use strict;
use warnings;

use Test::More;
use Sub::Debug;

is_deeply( Sub::Debug::_parse_line('my ($name) = @_;'), [qw/ $name /] );
is_deeply( Sub::Debug::_parse_line('my ($name, $name2) = @_;'),
    [qw/ $name $name2 /] );
is_deeply( Sub::Debug::_parse_line('my ($name, @name2) = @_;'),
    [qw/ $name @name2 /] );
is_deeply( Sub::Debug::_parse_line('my ( $name , @name2 , $name3 ) = @_;'),
    [qw/ $name @name2 $name3 /] );
is_deeply(
    Sub::Debug::_parse_line('my ( $name , @name2 , $name3 ) = (shift, @_);'),
    [qw/ $name @name2 $name3 /] );
is_deeply( Sub::Debug::_parse_line('my@name=@_;'), [qw/ @name /] );
is_deeply( Sub::Debug::_parse_line('( $name , @name2 , $name3 ) = @sth'),
    [qw/ /] );

done_testing();
