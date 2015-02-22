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
    use_ok( 'Helper' ) or exit;
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    copy => [ 'ubr00003.pdf' ],
});

my $pdf = Remedi::PDF::CAM::PDF->new(
    file => path($Bin, 'input_files', 'ubr00003.pdf')
);


my $filestem = $pdf->file->basename =~ qr/(.*)\.[^.]*$/;
$pdf->create_thumbnail(path($Bin, 'input_files', $filestem . '.gif'));

done_testing();
