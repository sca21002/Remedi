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
    log_level => 'OFF',                        # supress annoying logging
    creator => 'Universitätsbibliothek Regensburg',
    dest_format_key => 'PDF',
    library_union_id => 'bvb',
    isil => 'DE-355',
    logo_file_prefix => 'UBRLogo_',
    logo_url => 'http://www.bibliothek.uni-regensburg.de/',
    image_path => '.',
    image_basepath => path($Bin, 'input_files'),
    source_format => 'PDF',
    logo_path => path($Bin)->parent->child( qw( logo de-355 ) ),
    regex_filestem_prefix => qr/ubr\d{5}/,
    regex_filestem_var => qr/_\d{1,5}/,
    title => 'Mein Titel',
);
note("may take some time ..");
$task->make_footer;
done_testing();

