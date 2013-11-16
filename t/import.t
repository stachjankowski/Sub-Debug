use strict;
use warnings;

use Test::More;

use Sub::Debug 't::Log::Log';
use t::Log;
use t::Test;

t::Test::test();

ok( $t::Log::buffer =~ /Variables before executing t::Test::test/ );

done_testing();