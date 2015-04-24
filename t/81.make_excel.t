use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Data::Dumper;


BEGIN {
    use_ok( 'Remedi::Excel' ) or exit;
    use_ok( 'Helper' ) or exit;
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    rmdir_dirs => [ qw(ingest) ],
    make_path => [ qw(ingest) ],
    copy => [
        { glob => 'ubr00003_000?.tif',
          dir  => 'ingest',
        },
        { glob => 'ubr00003_000?.pdf',
          dir  => 'ingest',
        },        
        { glob => 'ubr00003_000?.gif',
          dir  => 'ingest',
        },         
    ],
});

$Remedi::VERSION = '0.05';

my $task = Remedi::Excel->new(
        creator => 'Universitätsbibliothek Regensburg',
        isil => 'DE-355',
        library_union_id => 'bvb',
        log_config_path => path($Bin, qw(config log4perl.conf)),
        image_path => '.',
        image_basepath => path($Bin, 'input_files'),
        regex_filestem_prefix => qr/ubr\d{5}/,
        regex_filestem_var => qr/_\d{1,5}/,
        title => 'My Title',
        _xml_config_file => path($Bin)->parent->child( qw( config excel.xml ) ),
);
my $order_id = $task->ingest_reference_files->[0]->order_id;
path($task->_excel_dir, $order_id . '.xls')->remove
    and note('removing old excel file');
$task->make_excel;

done_testing();

