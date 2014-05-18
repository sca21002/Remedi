use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Remedi::Types qw(B3KatID);


BEGIN {
    use_ok( 'Helper' ) or exit;
}

ok(1);

ok(is_B3KatID('BV021771940'));
#is_B3KatID('BV021771940_');

done_testing();
