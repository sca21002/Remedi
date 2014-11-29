use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
# use Devel::Leak::Object qw{ GLOBAL_bless };
# $Devel::Leak::Object::TRACKSOURCELINES = 1;
use Data::Dumper;


BEGIN {
    use_ok( 'Remedi::DigiFooter::App' ) or exit;
    use_ok( 'Helper' ) or exit;
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    rmdir_dirs => [ qw(pdf archive) ],
    make_path => [ qw(pdf) ],
    copy => [ qw(ubr00003*.tif log4perl.conf ubr00003.pdf) ],
    burst => [
        { glob => 'ubr00003.pdf',
          output => File::Spec->catfile('pdf', 'ubr00003_%04d.pdf'),
          dir => 'pdf',
        },
        
    ],    
});

ok(
    path('doc_data.txt')->remove
        or path($Bin, qw(input_files pdf doc_data.txt))->remove,
    'delete doc_data.txt'
);

my $task = Remedi::DigiFooter::App->new(
        logo_file_prefix_2 => 'SBRLogo_',
        logo_path_2 => path($Bin)->parent->child( qw( logo de-155 ) ),
        logo_url_2 =>'http://www.staatliche-bibliothek-regensburg.de/',
        creator => 'Universitätsbibliothek Regensburg',
        dest_format_key => 'PDF',
        log_configfile => path($Bin, qw(config log4perl.conf)),
        library_union_id => 'bvb',
        isil => 'DE-355',
        image_path => '.',
        image_basepath => path($Bin, 'input_files'),
        logo_file_prefix => 'UBRLogo_',
        logo_path => path($Bin)->parent->child( qw( logo de-355 ) ),
        logo_url => 'http://www.bibliothek.uni-regensburg.de/',
        regex_filestem_prefix => qr/ubr\d{5}/,
        regex_filestem_var => qr/_\d{1,5}/,
        resolution_correction => 1,
        source_format => 'PDF',
        source_pdf_dir => path($Bin, qw(input_files pdf)),
        title => 'Mein Titel',
);
note("may take some time ..");
$task->make_footer;
my $app = Log::Log4perl::Appender::TestBuffer->by_name("my_buffer");
like($app->buffer, qr/End: DigiFooter/, 'digifooter finished');
#diag $app->buffer;
done_testing();
