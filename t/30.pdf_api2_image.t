use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;

BEGIN {
    use_ok( 'Remedi::PDF::API2' ) or exit;
    use_ok( 'Helper' ) or exit;
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    copy => [ 'ubr16066_0373.pdf' ],
});

my $pdf = Remedi::PDF::API2->open(
    file => path( $Bin, qw(input_files ubr16066_0373.pdf) ),
);

is($pdf->size, 117712, 'size');
is(my @pages = $pdf->pages, 1, 'number of pages');
my $page = $pdf->openpage(1);
is($page->count_images, 3, 'number of images'); 

done_testing();
