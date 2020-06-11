# Created with: ./make_t.pl

# Contents:
#1 lop.lop
#2 switch_plain.def
#3 switch_plain.switch_plain

# To locate test #13 you can search for its name or the string '#13'

use strict;
use Test::More;
use Carp;
use Perl::Tidy;
my $rparams;
my $rsources;
my $rtests;

BEGIN {

    ###########################################
    # BEGIN SECTION 1: Parameter combinations #
    ###########################################
    $rparams = {
        'def'          => "",
        'lop'          => "-nlop",
        'switch_plain' => "-nola",
    };

    ############################
    # BEGIN SECTION 2: Sources #
    ############################
    $rsources = {

        'lop' => <<'----------',
# logical padding examples
$same =
  (      ( $aP eq $bP )
      && ( $aS eq $bS )
      && ( $aT eq $bT )
      && ( $a->{'title'} eq $b->{'title'} )
      && ( $a->{'href'} eq $b->{'href'} ) );

$bits =
    $top > 0xffff ? 32
  : $top > 0xff   ? 16
  : $top > 1      ? 8
  :                 1;

lc( $self->mime_attr('content-type')
        || $self->{MIH_DefaultType}
        || 'text/plain' );
----------

        'switch_plain' => <<'----------',
# must run with -nola to keep default from outdenting
use Switch::Plain;
my $r = 'fail';
my $x = int rand 100_000;
nswitch (1 + $x * 2) {
    case $x: {}
    default: {
        $r = 'ok';
    }
}
my @words = qw(speed me towards death);
$r = do {
    sswitch ($words[rand @words]) {
        case $words[0]:
        case $words[1]:
        case $words[2]:
        case $words[3]: { 'ok' }
        default: { 'wtf' }
    }
};
----------
    };

    ####################################
    # BEGIN SECTION 3: Expected output #
    ####################################
    $rtests = {

        'lop.lop' => {
            source => "lop",
            params => "lop",
            expect => <<'#1...........',
# logical padding examples
$same =
  ( ( $aP eq $bP )
      && ( $aS eq $bS )
      && ( $aT eq $bT )
      && ( $a->{'title'} eq $b->{'title'} )
      && ( $a->{'href'} eq $b->{'href'} ) );

$bits =
  $top > 0xffff ? 32
  : $top > 0xff ? 16
  : $top > 1    ? 8
  :               1;

lc( $self->mime_attr('content-type')
      || $self->{MIH_DefaultType}
      || 'text/plain' );
#1...........
        },

        'switch_plain.def' => {
            source => "switch_plain",
            params => "def",
            expect => <<'#2...........',
# must run with -nola to keep default from outdenting
use Switch::Plain;
my $r = 'fail';
my $x = int rand 100_000;
nswitch( 1 + $x * 2 ) {
    case $x: { }
  default: {
        $r = 'ok';
    }
}
my @words = qw(speed me towards death);
$r = do {
    sswitch( $words[ rand @words ] ) {
        case $words[0]:
        case $words[1]:
        case $words[2]:
        case $words[3]: { 'ok' }
      default: { 'wtf' }
    }
};
#2...........
        },

        'switch_plain.switch_plain' => {
            source => "switch_plain",
            params => "switch_plain",
            expect => <<'#3...........',
# must run with -nola to keep default from outdenting
use Switch::Plain;
my $r = 'fail';
my $x = int rand 100_000;
nswitch( 1 + $x * 2 ) {
    case $x: { }
    default: {
        $r = 'ok';
    }
}
my @words = qw(speed me towards death);
$r = do {
    sswitch( $words[ rand @words ] ) {
        case $words[0]:
        case $words[1]:
        case $words[2]:
        case $words[3]: { 'ok' }
        default: { 'wtf' }
    }
};
#3...........
        },
    };

    my $ntests = 0 + keys %{$rtests};
    plan tests => $ntests;
}

###############
# EXECUTE TESTS
###############

foreach my $key ( sort keys %{$rtests} ) {
    my $output;
    my $sname  = $rtests->{$key}->{source};
    my $expect = $rtests->{$key}->{expect};
    my $pname  = $rtests->{$key}->{params};
    my $source = $rsources->{$sname};
    my $params = defined($pname) ? $rparams->{$pname} : "";
    my $stderr_string;
    my $errorfile_string;
    my $err = Perl::Tidy::perltidy(
        source      => \$source,
        destination => \$output,
        perltidyrc  => \$params,
        argv        => '',             # for safety; hide any ARGV from perltidy
        stderr      => \$stderr_string,
        errorfile => \$errorfile_string,    # not used when -se flag is set
    );
    if ( $err || $stderr_string || $errorfile_string ) {
        print STDERR "Error output received for test '$key'\n";
        if ($err) {
            print STDERR "An error flag '$err' was returned\n";
            ok( !$err );
        }
        if ($stderr_string) {
            print STDERR "---------------------\n";
            print STDERR "<<STDERR>>\n$stderr_string\n";
            print STDERR "---------------------\n";
            ok( !$stderr_string );
        }
        if ($errorfile_string) {
            print STDERR "---------------------\n";
            print STDERR "<<.ERR file>>\n$errorfile_string\n";
            print STDERR "---------------------\n";
            ok( !$errorfile_string );
        }
    }
    else {
        if ( !is( $output, $expect, $key ) ) {
            my $leno = length($output);
            my $lene = length($expect);
            if ( $leno == $lene ) {
                print STDERR
"#> Test '$key' gave unexpected output.  Strings differ but both have length $leno\n";
            }
            else {
                print STDERR
"#> Test '$key' gave unexpected output.  String lengths differ: output=$leno, expected=$lene\n";
            }
        }
    }
}
