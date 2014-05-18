use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;

BEGIN {
    use_ok( 'Remedi::Singlepage::TIFF' ) or exit;
    use_ok( 'Remedi::Imagefile::Archive') or exit;
    use_ok( 'Remedi::Units') or exit;
    use_ok( 'Helper' ) or exit;
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
    input_dir => path($Bin, 'input_files'),
    copy => [ 'ubr00003_0001.tif' ],
});

my $tiff = Remedi::Singlepage::TIFF->new(
    logo_path_2 => path($Bin)->parent->child( qw( logo de-155) ),
    logo_file_prefix_2 => 'SBRLogo_',
    creator_pdf_info => 'Digitalisiert von der UB Regensburg',
    footer_background => { color   => '#E0E0E0', grayscale => '#E0E0E0',
                           monochrome => 'white' },
    footer_color      => { color   => 'black', grayscale => 'black',
                           monochrome => 'black' },
    footer_height     => { small =>  7 * pt_pro_mm, large => 10 * pt_pro_mm },
    footer_logo_file_infix => { color   => 'farbig', grayscale => 'grau',
                                monochrome => 'sw' },
    footer_logo_width => { small => 25 * pt_pro_mm, large => 35 * pt_pro_mm },
    image => Remedi::Imagefile::Archive->new(
        dest_format => 'TIFF',
        file => path($Bin, qw(input_files ubr00003_0001.tif)),
        isil => 'DE-355',
        library_union_id => 'bvb',
        profile => 1,
        regex_filestem_prefix => qr/ubr\d{5}/,
        regex_filestem_var => qr/_\d{1,5}/,
        size_class_border => 150 * pt_pro_mm,
        sRGB_profile => path(__FILE__)->parent(2)->child(
                            qw( color sRGB_Color_Space_Profile.icm )
                        ),
    ),
    logo_file_prefix => 'UBRLogo_', 
    logo_path => path($Bin)->parent->child( qw( logo de-355 ) ),
    profile => 1,
    urn_font_size => 8,
    urn_font_type => 'Helvetica',
    urn_level => 'single_page',
);
my $dest_dir = path($Bin, qw(input_files reference_new) );
$dest_dir->mkpath;

$tiff->create_footer($dest_dir,'TIFF');

done_testing();


