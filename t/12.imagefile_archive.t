use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Test::Fatal;

BEGIN {
    use_ok( 'Remedi::Imagefile::Archive' ) or exit;
    use_ok( 'Remedi::Units' ) or exit;
    use_ok( 'Log::Log4perl' ) or exit;
    my $conf = q {
        log4perl.rootLogger=INFO, TestBuffer
        log4perl.appender.TestBuffer = Log::Log4perl::Appender::TestBuffer
        log4perl.appender.TestBuffer.layout = SimpleLayout
    };
    Log::Log4perl->init(\$conf);
    use_ok( 'Helper' ) or exit;
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    copy => [ qw(ubr00003_0003.tif ubr12225_0001.tif) ],
});


my $imagefile = Remedi::Imagefile::Archive->new(
    library_union_id => 'bvb',
    isil => 'DE-355',
    file => path($Bin, 'input_files', 'ubr00003_0003.tif'),
    profile => 1,
    regex_filestem_prefix => qr/ubr\d{5}/,
    regex_filestem_var => qr/_\d{1,5}/,
    size_class_border => 150 * pt_pro_mm,
    sRGB_profile => path(__FILE__)->parent(2)->child(
                        qw( color sRGB_Color_Space_Profile.icm )
                    ),
    thumbnail_format => 'GIF',
    thumbnail_height => 300,
);

ok(-e $imagefile->sRGB->stringify, 'imagefile->sRGB');
note($imagefile->sRGB->stringify, ' created.');
ok(-e $imagefile->jpeg->stringify, 'imagefile->jpeg');
note($imagefile->jpeg->stringify, ' created.');
$imagefile->create_thumbnail($imagefile->tempdir);
ok(-e path($imagefile->tempdir, 'ubr00003_0003.gif'), 'thumbnail');
is($imagefile->get_niss,'ubr00003-0003-', 'imagefile->get_niss');

my $imagefile_monochrome = Remedi::Imagefile::Archive->new(
    library_union_id => 'bvb',
    isil => 'DE-355',
    file => path($Bin, 'input_files', 'ubr12225_0001.tif'),
    profile => 1,
    regex_filestem_prefix => qr/ubr\d{5}/,
    regex_filestem_var => qr/_\d{1,5}/,
    size_class_border => 150 * pt_pro_mm,
    sRGB_profile => path(__FILE__)->parent(2)->child(
                        qw( color sRGB_Color_Space_Profile.icm )
                    ),
);
like(
    exception { $imagefile_monochrome->jpeg },
    qr/converting to JPEG only implemented for TIFF files in color/,
    'caught converting to JPEG of monochrome TIFF'
);

done_testing();
