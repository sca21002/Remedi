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
    input_dir => path($Bin, 'input_files'),
    rmdir_dirs => [ qw(ingest) ],
    make_path => [ qw(ingest) ],
    copy => [
        { glob => 'ubr00003_000?.tif',
          dir  => 'ingest',
        },
        { glob => 'ubr00003_000[1,2].pdf',
          dir  => 'ingest',
        },
        { glob => 'ubr00003_0003.jp2',
          dir  => 'ingest',
        },        
        { glob => 'ubr00003_000?.gif',
          dir  => 'ingest',
        },
        
    ],
});

my $task = Remedi::Excel->new(
        creator => 'Universitätsbibliothek Regensburg', 
        log_configfile => path($Bin, qw(config log4perl.conf)),
        image_basepath => path($Bin, 'input_files'),
        image_path => '.',
        library_union_id => 'bvb',
        isil => 'DE-355',
        regex_filestem_prefix => qr/ubr\d{5}/,
        regex_filestem_var => qr/_\d{1,5}/,
        title => 'My Title',
        _xml_config_file => path($Bin)->parent->child( qw( config excel.xml ) ),
);
my $order_id = $task->ingest_reference_files->[0]->order_id;
path($task->_excel_dir, $order_id . '.xls')->remove
    and note('Removing old excel file');
$task->make_excel;

done_testing();


