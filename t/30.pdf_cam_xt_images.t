use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Remedi::ImageMagickCmds;

BEGIN {
    use_ok( 'Remedi::PDF::CAM::PDF' ) or exit;
    use_ok( 'Remedi::PDF::CAM::PDF::Page') or exit;
    use_ok( 'Helper' ) or exit;
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    copy => [ 'ubr16066_0373.pdf' ],
});

my $pdf = Remedi::PDF::CAM::PDF->new(
    file => path($Bin, 'input_files', 'ubr16066_0373.pdf')
);

is ($pdf->numPages(), 1, 'number of pages = 1');

my $expected = [ {1 => 2} ];
my $xt_images = $pdf->extra_images;
is_deeply($xt_images, $expected, '2 extra images found');

done_testing();
