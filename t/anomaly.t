use strict;
use warnings;

use Test::More;
use Test::Exception;
use Sub::Debug;

SKIP: {
    eval { require File::Temp };
    skip "File::Temp not installed", 1 if $@;

    my $fh       = File::Temp->new();
    my $filename = $fh->filename;
    chmod 0200, $filename;    # no rights to write

    dies_ok { Sub::Debug::_get_assignment_line( $filename, 'test' ) };
}

done_testing();
