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

use warnings  qw(FATAL utf8);    # fatalize encoding glitches
use open      qw(:std :utf8);    # undeclared streams in UTF-8

binmode Test::More->builder->output, ":utf8";
binmode Test::More->builder->failure_output, ":utf8";

BEGIN {
    use_ok( 'Remedi::DigiFooter::App' ) or exit;
    use_ok( 'Helper' ) or exit;
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    rmdir_dirs => [ 'archive' ],
    copy => [qw(ubr00003*.tif ubr00003.pdf)],
});

my $task = Remedi::DigiFooter::App->new_with_config(
    configfile => path($Bin, qw(config remedi_de-355.conf)),
    dest_format_key => 'PDF',
    log_config_path => path(
            $Bin, qw( config log4perl_appender_file.conf )
        )->stringify,
    image_basepath => path($Bin, 'input_files'),
    source_format => 'PDF',
    source_pdf_name => path($Bin, qw(input_files ubr00003.pdf))->stringify,
    logo_path => [ '__HOME__', qw( logo de-355 ) ],
    title => 'Mein Titel',
    author => 'Mein Autor',
    logo_path_2 => path($Bin)->parent->child( qw( logo de-155 ) ),
    logo_file_prefix_2 => 'SBRLogo_',
    logo_url_2 => 'http://www.staatliche-bibliothek-regensburg.de/',
    resolution_correction => 1,
);
note("may take some time ..");
$task->make_footer;
my $app = Log::Log4perl::Appender::TestBuffer->by_name("my_buffer");
like($app->buffer, qr/End: DigiFooter/, 'digifooter finished');
#diag $app->buffer;
is($task->logo_path, path($Bin)->parent->child( qw( logo de-355 ) ),
   'logo path');
done_testing();
