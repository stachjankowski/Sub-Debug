use strict;
use warnings;

use Test::More;
use Sub::Debug;

my ( $x, $y, @x, @y );

sub a { my @a = qw(a b c); @a }
sub b : Debug { &a }
is_deeply( [ b() ], [ a() ] );

($x) = a();
($y) = b();
is( $y, $x );

@x = a();
@y = b();
is_deeply( [@y], [@x] );

$x = a();
$y = b();
is( $y, $x );

sub c         { qw(a b c) }
sub d : Debug { &c }
is_deeply( [ d() ], [ c() ] );

($x) = c();
($y) = d();
is( $y, $x );

@x = c();
@y = d();
is_deeply( [@y], [@x] );

$x = c();
$y = d();
is( $y, $x );

sub e         { qw() }
sub f : Debug { &e }
is_deeply( [ f() ], [ e() ] );

($x) = e();
($y) = f();
is( $y, $x );

@x = e();
@y = f();
is_deeply( [@y], [@x] );

$x = e();
$y = f();
is( $y, $x );

sub g : Debug {
    my ( $x, $y, %z ) = @_;

    return {
        x => $x,
        y => $y,
        z => \%z
    };
}
my $result = g( 5, 6, a => 7, b => 8 );
is_deeply( $result, { x => 5, y => 6, z => { a => 7, b => 8 } } );

done_testing();
