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

my $task = Remedi::Excel->new_with_config(
        configfile => path($Bin, qw(config remedi_de-355.conf)),
        title => 'My Title',
);
my $order_id = $task->ingest_reference_files->[0]->order_id;
path($task->_excel_dir, $order_id . '.xls')->remove
    and note('removing old excel file');
$task->make_excel;

done_testing();

