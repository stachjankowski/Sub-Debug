package Sub::Debug;

use strict;
use warnings;

our $VERSION;
BEGIN {
    $VERSION = '0.0';
};

use Attribute::Handlers;
use B;
use Data::Dumper;
use List::MoreUtils qw/any none firstidx/;
use Module::Load;
use PadWalker qw/peek_sub/;

my $log_handler;

sub import {
    my $class = shift;
    if ( ref($_[0]) eq 'CODE' ) {
        $log_handler = shift;
        return;
    }
    my $full_sub_name = shift;
    if ( $full_sub_name && $full_sub_name =~ /::/ ) {
        $full_sub_name =~ /^(.*)::(.*?)$/;
        my ($pkg, $subname) = ($1, $2);
        eval {
            load $pkg;
            $log_handler = *{$full_sub_name};
        }
    }
    unless ( $log_handler ) {
        $log_handler = sub { print @_ };
    }
}
sub UNIVERSAL::Debug : ATTR(CODE) {
    my ($package, $symbol, $referent, undef, $data, undef, $filename) = @_;
    $filename ||= locate_file_by_package($package);
    my $cv = B::svref_2object( $symbol );
    my %params = @{$data || []};
    my $full_sub_name = $package."::".$cv->SAFENAME();
    my @in_names = _in_names($filename, $cv->NAME);

    no warnings 'redefine';
    *{$symbol} = sub {
        my $in_vars = _bind_in_vars(\@in_names, [@_]);
        my $direction = $params{'include'} ? 'include'             : $params{'exclude'} ? 'exclude'             : '';
        my @names     = $params{'include'} ? @{$params{'include'}} : $params{'exclude'} ? @{$params{'exclude'}} : ();
        my $sub_vars = peek_sub($referent);
        _filter_variables($direction, $sub_vars, @names);
        _filter_variables($direction, $in_vars, @names);
        my $before_vars = {
            'in'        => $in_vars,
            'mem_usage' => mem_usage()
        };
        my $after_vars = {
            'sub'     => $sub_vars
        };

        my $uniqID = sprintf "%07p", rand;
        my $ref;
        $ref = eval('$' . $package . '::' . $params{'ref'}) if $params{'ref'};
        local $Data::Dumper::Terse = 1;
        {
            local $Data::Dumper::Sortkeys = _get_sort_sub(@in_names);
            if ( $params{'ref'} ) {
                $ref->{'before'} = $before_vars;
            } else {
                $log_handler->("Variables before executing $full_sub_name (uniqID: $uniqID ):\n" . Dumper $before_vars);
            }
        }
        my (@ret, $ret, $err);
        my $what_you_want = wantarray ? 'wantarray' : defined wantarray ? 'scalar' : 'nothing';
        eval {
            if ($what_you_want eq 'wantarray') {
                @ret = &{$referent};
            } elsif ($what_you_want eq 'scalar') {
                $ret = &{$referent};
            } else {
                &$referent;
            }
            1;
        } or do {
            $err = $@
        };

        if ($what_you_want eq 'wantarray') {
            $after_vars->{'return'} = \@ret;
        } elsif ($what_you_want eq 'scalar') {
            $after_vars->{'return'} = \$ret;
        }
        $after_vars->{'error'} = "$err" if $err;
        $after_vars->{'mem_usage'} = mem_usage();
        $after_vars->{'memory_leak'} = $after_vars->{'mem_usage'} - $before_vars->{'mem_usage'};
        if ( $params{'ref'} ) {
            $ref->{'after'} = $after_vars;
        } else {
            $log_handler->("Variables after executing $full_sub_name (uniqID: $uniqID ):\n" . Dumper $after_vars);
        }

        die($err) if $err;  # re raise error

        return
            $what_you_want eq 'wantarray' ? @ret
          : $what_you_want eq 'scalar'    ? $ret
          : ();
    }
}

sub _get_sort_sub {
    my @in_names = @_;
    my %idxs;
    my $idx = sub {
        return $idxs{$_[0]} if $idxs{$_[0]};
        $idxs{$_[0]} = firstidx { $_ eq $_[0] } @in_names;
        return $idxs{$_[0]};
    };
    return sub {
        [
            sort {
                $idx->($a) > -1 && $idx->($b) > -1 ?
                    $idx->($a) <=> $idx->($b)
                    : lc substr($a,1) cmp lc substr($b,1)
            } keys %{$_[0]}
        ]
    }
}

sub _in_names {
    my ($file, $subname) = @_;
    return @{ _parse_line(_get_assignment_line($file, $subname)) };
}

sub _bind_in_vars {
    my ($in_names, $in_values) = @_;
    my $in_vars;
    foreach ( @$in_names ) {
        my $first_char = substr($_,0,1);
        if ( $first_char eq '$' ) {
            $in_vars->{$_} = \shift(@$in_values);
        } elsif ( $first_char eq '@' ) {
            $in_vars->{$_} = [@$in_values];
            @$in_values = ();
            last;
        } elsif ( $first_char eq '%' ) {
            $in_vars->{$_} = {@$in_values};
            @$in_values = ();
            last;
        }
    }
    if ( @$in_values ) {
        $in_vars->{'@_'} = [@$in_values];
    }
    return $in_vars;
}


sub _get_assignment_line {
    my ( $file, $subname ) = @_;

    die("Filename $file does not exists") unless -e $file;
    die("No subname specified") unless $subname;

    my ($buffer, $match);
    open my $FH, '<', $file or die("Problem with opening $file");
    while ( my $line = <$FH> ) {
        chomp $line;
        if ( $line =~ / sub \s* $subname \b /x || $match ) {
            $buffer .= $line;
            last if $match;
            $match = 1;
        } else {
            $match = 0;
        }
    }
    close $FH;
    return ($buffer =~ /( my .* ; )/x) ? $1 : '';
}

sub _parse_line {
    return shift =~ / my \s* \(? (.*?) [\)|=] /x ?
      [ map { /^ \s* (.*?) \s* $/x && $1 } split /,/, $1 ]
      : []
}

sub _filter_variables {
    my ($direction, $vars, @names) = @_;

    if ( $direction eq 'include' ) {
        foreach my $key (keys %{$vars}) {
            if ( none { $_ eq $key } @names ) {
                delete $vars->{$key};
            }
        }
    } elsif ( $direction eq 'exclude' ) {
        foreach my $key (keys %{$vars}) {
            if ( any { $_ eq $key } @names ) {
                delete $vars->{$key};
            }
        }
    }
}

sub locate_file_by_package {
   my $file = shift;
   #use Log;
   $file =~ s@ \:\: @/@gx;
   $file = "$file.pm";
   #Log::Info( 'marker', $file, -e $file );
   return -e $file ? $file : "";
}

sub mem_usage {
   open(my $statm, "<", "/proc/$$/statm");
   my @stat = split /\s+/, <$statm>;
   close $statm;
   return $stat[1] * .004;
}

1;