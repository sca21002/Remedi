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
    use_ok( 'Remedi::CSV' ) or exit;
    use_ok( 'Helper' ) or exit;
}


BEGIN {
    use_ok( 'Remedi::CSV::App' ) or exit;
    use_ok( 'Helper' ) or exit;
}

Helper::prepare_input_files({
    input_dir => path($Bin, 'input_files'),
    rmdir_dirs => [ qw(archive reference  ingest) ],
    make_path => [ qw(archive reference) ],
    copy => [
        { glob => 'ubr00003_000?.tif',
          dir  => 'archive',
        },
        { glob => 'ubr00003_000[1,2].pdf',
          dir  => 'reference',
        },
        { glob => 'ubr00003_0003.jp2',
          dir  => 'reference',
        }, 
    ],
});

my $task = Remedi::CSV::App->new(
    image_basepath => path($Bin, 'input_files'),
    image_path => '.',
    isil => 'DE-355',
    library_union_id => 'bvb',
    log_config_path => path($Bin, qw(config log4perl.conf)),
    regex_filestem_prefix => qr/ubr\d{5}/,
    regex_filestem_var => qr/_\d{1,5}/,
    title => 'My Title',
); 
$task->make_csv;

done_testing();
