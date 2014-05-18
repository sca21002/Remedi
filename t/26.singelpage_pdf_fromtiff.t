use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;



BEGIN {
    use_ok( 'Remedi::Singlepage::PDF::FromTIFF' ) or exit;
    use_ok( 'Remedi::Imagefile') or exit;
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

my $pdf = Remedi::Singlepage::PDF::FromTIFF->new(
    author => ' ',
    creator_pdf_info => 'Digitalisiert von der UB Regensburg',
    footer_background => { color   => '#E0E0E0', grayscale => '#E0E0E0',
                           monochrome => 'white' },
    footer_color      => { color   => 'black', grayscale => 'black',
                           monochrome => 'black' },
    footer_height     => { small =>  7 * pt_pro_mm, large => 10 * pt_pro_mm },
    footer_logo_file_infix => { color   => 'farbig', grayscale => 'grau',
                                monochrome => 'sw' },
    footer_logo_width => { small => 25 * pt_pro_mm, large => 35 * pt_pro_mm },
    image => Remedi::Imagefile->new(
        library_union_id => 'bvb',
        isil => 'DE-355',
        file => path($Bin, qw(input_files ubr00003_0001.tif) ),
        regex_filestem_prefix => qr/ubr\d{5}/,
        regex_filestem_var => qr/_\d{1,5}/,
        size_class_border => 150 * pt_pro_mm,
    ),                            
    logo_file_prefix => 'UBRLogo_',
    logo_path => path($Bin)->parent->child(qw(logo de-355)),
    logo_url => 'http://www.bibliothek.uni-regensburg.de/',
    page_num    => 1,
    pages_total => 3,
    title => 'Title',
    urn_font_size => 8,
    urn_font_type => 'Helvetica',
    urn_resolver_base => 'http://www.nbn-resolving.de/',
);

is($pdf->colortype,'color', 'colortype');
is($pdf->size_class,'small', 'size_class');
is(
    sprintf("%.1f",$pdf->footer_height->{$pdf->size_class}*25.4/72),
    '7.0','size_class'
);
is($pdf->logo_file,
  path($Bin)->parent->child(
    qw( logo de-355 UBRLogo_farbig_25_7.pdf) ), 'logo_file'
);
my @box = (0, 0, 413, 682.842519685039);
is_deeply($pdf->mediabox, \@box, 'mediabox');
eq_array($pdf->mediabox, $pdf->cropbox, 'mediabox eq cropbox');
is($pdf->page_num, 1, 'page_num');
is($pdf->pages_total, 3, 'pages_total');
is($pdf->scaling_factor, 0.96, 'scaling_factor');
is($pdf->filestem,'ubr00003_0001', 'filestem');

done_testing();
