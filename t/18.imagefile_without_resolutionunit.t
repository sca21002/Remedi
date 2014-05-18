use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;

BEGIN {
    use_ok( 'Remedi::Imagefile' ) or exit;
    use_ok( 'Remedi::Units' ) or exit;
    use_ok( 'Helper' ) or exit;
    use_ok( 'Log::Log4perl', qw(:easy) ) or exit;
    ok(Log::Log4perl->easy_init(), 'init logging' );
    use_ok( 'IO::CaptureOutput', qw(capture) );
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    copy => [ 'ubr12224_0135.tif' ],
});

my ($stderr, $stdout);
my $imagefile;

$imagefile = Remedi::Imagefile->new(
    library_union_id => 'bvb',
    isil => 'DE-355',
    file => path($Bin, 'input_files', 'ubr12224_0135.tif'),
    regex_filestem_prefix => qr/ubr12224/,
    regex_filestem_var => qr/_\d{1,5}/,
    size_class_border => 150 * pt_pro_mm,
);

is($imagefile->colortype, 'grayscale', 'colortype');
is($imagefile->format, 'TIFF', 'format');
is($imagefile->height_px, 2041, 'height_px');
is($imagefile->id, 'ubr12224_0135_tif_file', 'id');
is($imagefile->path_abs_str,
    path($Bin, qw(input_files ubr12224_0135.tif)),'file'
);
is($imagefile->basename, 'ubr12224_0135.tif', 'basename');
is($imagefile->size, '73964', 'size');
capture {
    is($imagefile->resolution, '300', 'resolution');
} undef, \$stderr;
like($stderr, qr/ResolutionUnit None/, 'caught ResolutionUnit None');
my @box = (0,0,346,490);
is_deeply($imagefile->mediabox, \@box, 'mediabox');
is($imagefile->order_id, 'ubr12224', 'order_id');
is($imagefile->size_class, 'small', 'size_class');
is($imagefile->width_px, '1440', 'width_px');

done_testing();
 
