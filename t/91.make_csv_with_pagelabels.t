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
    use_ok( 'Remedi::CSV::App' ) or exit;
    use_ok( 'Helper' ) or exit;
    use_ok('Remedi::PDF::API2') or exit;
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    rmdir_dirs => [ qw(archive reference ingest) ],
    make_path => [ qw(archive reference) ],
    copy => [
        { glob => 'ubr00003_000?.tif',
          dir  => 'archive',
        },
        { glob => 'ubr00003_000?.pdf',
          dir  => 'reference',
        },        
        { source => 'ubr00003_with_pagelabels.pdf',
          dest   => 'ubr00003.pdf',
        },
    ],
});

my $task = Remedi::CSV::App->new(
    image_basepath => path($Bin, 'input_files'),
    image_path => '.',
    library_union_id => 'bvb',
    isil => 'DE-355',
    log_config_path => path($Bin, qw(config log4perl.conf)),
    regex_filestem_prefix => qr/ubr\d{5}/,
    regex_filestem_var => qr/_\d{1,5}/,
    source_pdf_file  => path($Bin, qw(input_files ubr00003.pdf) ),
    title => 'My Title',
);

$task->make_csv();

#diag Dumper($task->source_pdf->pagelabels->sequence);

done_testing();
