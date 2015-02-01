use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Test::Fatal;
use Remedi::Types qw(B3KatID JPEG2000List);
use Data::Dumper;

BEGIN {
    use_ok( 'Helper' ) or exit;
}

ok(is_B3KatID('BV021771940'), 'Is a B3Kat Id');
ok(! is_B3KatID('BV021771940_'), 'Is no B3Kat Id');

ok(is_JPEG2000List({1 => 1, 25 => 1}), 'Is a JPEG2000List');

my $list = {
    '1'  => 1,
    '3'  => 1,
    '4'  => 1,
    '5'  => 1,
    '25' => 1,
};

is_deeply(to_JPEG2000List(' 1, 3-5, 25'), $list, 'JPEG2000 list'); 

done_testing();
