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
    rmdir_dirs => [ 'archive' ],
    copy => [qw(ubr00003*.tif ubr00003.pdf)],
});

my $task = Remedi::DigiFooter::App->new(
    logo_file_prefix_2 => 'SBRLogo_',
    logo_path_2 => path($Bin)->parent->child( qw( logo de-155 ) ),
    logo_url_2 => 'http://www.staatliche-bibliothek-regensburg.de/',
    logo_path_3 => path($Bin)->parent->child( qw( logo de-M135 ) ),
    author => 'Mein Autor',
    creator => 'Universitätsbibliothek Regensburg',
    dest_format_key => 'PDF',
    isil => 'DE-355',
    library_union_id => 'bvb',
    log_config_path => path($Bin, qw(config log4perl.conf)),
    logo_file_prefix => 'UBRLogo_',
    logo_path => path($Bin)->parent->child( qw( logo de-355 ) ),
    logo_url => 'http://www.bibliothek.uni-regensburg.de/',
    image_path => '.',
    image_basepath => path($Bin, 'input_files'),
    regex_filestem_prefix => qr/ubr\d{5}/,
    regex_filestem_var => qr/_\d{1,5}/,
    resolution_correction => 1,
    source_format => 'PDF',
    source_pdf_name => path($Bin, qw(input_files ubr00003.pdf))->stringify,
    logo_file_prefix_3 => 'IOSLogo_',
    logo_url_3 => 'http://www.ios-regensburg.de/',
    title => 'Mein Titel',
);
note("may take some time ..");
$task->make_footer;
my $app = Log::Log4perl::Appender::TestBuffer->by_name("my_buffer");
like($app->buffer, qr/End: DigiFooter/, 'digifooter finished');
#diag $app->buffer;
done_testing();

