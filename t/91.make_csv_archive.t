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
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    rmdir_dirs => [ qw(archive) ],
    make_path => [ qw(archive) ],
    copy => [
        { glob => 'ubr00003_000?.tif',
          dir  => 'archive',
        },
    ],
});

my $task = Remedi::CSV::App->new(
    image_basepath => path($Bin, 'input_files'),
    image_path => '.',
    log_config_path => path($Bin, qw(config log4perl.conf)),
    isil => 'DE-355',
    library_union_id => 'bvb',
    regex_filestem_prefix => qr/ubr\d{5}/,
    regex_filestem_var => qr/_\d{1,5}/,
    title => 'My Title',
); 
$task->make_csv;

done_testing();
