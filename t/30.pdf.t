use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;

BEGIN {
    use_ok( 'Remedi::PDF::CAM::PDF' ) or exit;
    use_ok( 'Helper' ) or exit;
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    copy => [ 'ubr00003.pdf' ],
});

my $pdf = Remedi::PDF::CAM::PDF->new(
    file => path($Bin, qw(input_files ubr00003.pdf))
);

is($pdf->size, '410120','size');
is($pdf->numPages,'3','number of pages');
is($pdf->pdfversion,'1.4','Version of PDF');
my $expected = {
    ModDate => "D:20140222121010+01'00'",
#    Subject => '',
    Creator => 'Adobe Acrobat 9.0',
#   Keywords => '',
    Title => '',
    CreationDate => "D:20130923154622+02'00'",
    Producer => 'Adobe Acrobat 9.0 Image Conversion Plug-in',
#    Author => ''
};
is_deeply($pdf->pdfinfo, $expected, 'PDF-Info');

done_testing();
