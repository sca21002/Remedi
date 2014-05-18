use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Test::Deep;

BEGIN {
    use_ok( 'Remedi::PDF::Pagelabels' ) or exit;
    use_ok( 'Remedi::PDF::Pagelabel' )  or exit;
    use_ok( 'Helper' ) or exit;
}

my $pagelabels = Remedi::PDF::Pagelabels->new(number_of_pages => 18);

$pagelabels->add(Remedi::PDF::Pagelabel->new(
    page_no => 0,
    style => 'Roman')
);
$pagelabels->add(Remedi::PDF::Pagelabel->new(
    page_no => 3,
    style => 'Alpha',
    prefix => 'Seite ',
    start => 2)
);
$pagelabels->add(Remedi::PDF::Pagelabel->new(
    page_no => 8,
    style => 'alpha',
    prefix => '',
    start => 1)
);

$pagelabels->add(Remedi::PDF::Pagelabel->new(
    page_no => 12,
) );

$pagelabels->add(Remedi::PDF::Pagelabel->new(
    page_no => 15,
    style => 'decimal',
    start => 3,
) );

my $sequence = [ qw(I II III), 'Seite B', 'Seite C', 'Seite D', 'Seite E',
    'Seite F', qw(a b c d), ('') x 3, 3, 4, 5 ];

cmp_deeply($pagelabels->sequence, $sequence, 'got sequence');

done_testing();