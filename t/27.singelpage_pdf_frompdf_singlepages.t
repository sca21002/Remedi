use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Cwd;

BEGIN {
    use_ok( 'Remedi::Singlepage::PDF::FromPDF' ) or exit;
    use_ok( 'Remedi::Imagefile') or exit;
    use_ok( 'Remedi::Units') or exit;
    use_ok( 'Helper' ) or exit;
    use_ok( 'Log::Log4perl', qw(:easy) ) or exit;
    ok(Log::Log4perl->easy_init(), 'init logging' );
}

Helper::prepare_input_files({
    input_dir => path($Bin, 'input_files'),
    rmdir_dirs => [ qw(pdf) ],
    make_path => [ qw(pdf) ],
    copy => [ qw(ubr00003_0001.tif log4perl.conf ubr00003.pdf) ],
    burst => [
        { glob => 'ubr00003.pdf',
          output => path('pdf', 'ubr00003_%04d.pdf')->stringify,
          dir => 'pdf',
        },
        
    ],    
});

Log::Log4perl->init(path($Bin, qw(input_files log4perl.conf))->stringify);

my $pdf = Remedi::Singlepage::PDF::FromPDF->new(
    creator_pdf_info => 'Digitalisiert von der UB Regensburg',
    deviation_width_height_tolerance_percent => 12,
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
        file => path($Bin, qw(input_files ubr00003_0001.tif)),
        regex_filestem_prefix => qr/ubr\d{5}/,
        regex_filestem_var => qr/_\d{1,5}/,
        size_class_border => 150 * pt_pro_mm,
    ),
    logo_file_prefix => 'UBRLogo_',    
    logo_path => path($Bin)->parent->child( qw( logo de-355 ) ),
    logo_url => 'http://www.bibliothek.uni-regensburg.de/',
    scaling_factor_tolerance_percent => 3,
    source_pdf => Remedi::PDF::API2->open(file =>
        path($Bin, qw(input_files pdf ubr00003_0001.pdf))->stringify
    ),
    title => 'Titel',
    page_num    => 1,
    pages_total => 3,
    urn_font_size => 8,
    urn_font_type => 'Helvetica',
    urn_resolver_base => 'http://www.nbn-resolving.de/',
);

is($pdf->colortype,'color','colortype');
is($pdf->size_class,'small','size_class');
is(
    sprintf("%.1f",$pdf->footer_height->{$pdf->size_class}*25.4/72),
    '7.0','size_class'   
);
is($pdf->logo_file,
  path($Bin)->parent->child(
        qw( logo de-355 UBRLogo_farbig_25_7.pdf ) ), 'logo_file',
);
my @box = (0,0,412.8,683.202519685039);
is_deeply($pdf->mediabox, \@box,'mediabox');
eq_array($pdf->mediabox, $pdf->cropbox,'mediabox eq cropbox');
is($pdf->page_num, 1,'page_num');
is($pdf->pages_total, 3,'pages_total');
is($pdf->scaling_factor,1,'scaling_factor');
is($pdf->filestem,'ubr00003_0001','filestem');
ok(
    path(getcwd, 'doc_data.txt')->remove
        or path($Bin, qw(input_files pdf doc_data.txt))->remove,
    'delete doc_data.txt'
);
done_testing();
