use strict;
use warnings;

package t::Log;

our $buffer = '';
sub Log {
    $buffer .= shift;
}

1;