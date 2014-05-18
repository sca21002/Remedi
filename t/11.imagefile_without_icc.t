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
    use_ok( 'Remedi::Imagefile' ) or exit;
    use_ok( 'Remedi::Units' ) or exit;
    use_ok( 'Helper' ) or exit;
    use_ok(' Log::Log4perl' ) or exit;
    my $conf = q {
        log4perl.rootLogger =DEBUG, TestBuffer
        log4perl.appender.TestBuffer = Log::Log4perl::Appender::TestBuffer
        log4perl.appender.TestBuffer.layout = SimpleLayout
        log4perl.appender.TestBuffer.name = my_buffer
        log4perl.appender.TestBuffer.utf8 = 1
    };
    Log::Log4perl->init(\$conf);
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    copy => [ qw(ubr13400_0001.tif) ],
});

my $imagefile = Remedi::Imagefile->new(
    library_union_id => 'bvb',
    isil => 'DE-355',
    file => path($Bin, 'input_files', 'ubr13400_0001.tif'),
    regex_filestem_prefix => qr/ubr\d{5}/,
    regex_filestem_var => qr/_\d{1,5}/,
    size_class_border => 150 * pt_pro_mm,
);

is($imagefile->colortype, 'color', 'colortype');
is($imagefile->format, 'TIFF', 'format');
is($imagefile->height_px, 672, 'height_px');
is($imagefile->id, 'ubr13400_0001_tif_file', 'id');
is($imagefile->path_abs_str,
   path($Bin, qw(input_files ubr13400_0001.tif))->absolute->stringify, 'file'
);
is($imagefile->basename, 'ubr13400_0001.tif','basename');
is($imagefile->size, '1019592','size');
my @box = (0,0,475,645);
is_deeply($imagefile->mediabox, \@box,'mediabox');
is($imagefile->order_id, 'ubr13400','order_id');
is($imagefile->resolution, '75','resolution');
is($imagefile->size_class, 'large','size_class');
is($imagefile->width_px, '495','width_px');
is($imagefile->icc_profile, undef, 'ICC-profile');


done_testing();