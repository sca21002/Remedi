use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Test::Output qw(stderr_from);

BEGIN {
    use_ok( 'Remedi::Cmd' ) or exit;
    use_ok( 'Helper' ) or exit;
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    rmdir_dirs => [ 'archive' ],
    make_path  => [ 'archive' ],
    copy => [ { 
        glob => 'ubr00003_000?.tif',
        dir  => 'archive',
    } ],
});

note("may take some time ..");

my $log_config_path = path($Bin, qw( config log4perl_screen.conf ) );
my $tiff_dir       = path($Bin, qw(input_files archive ) );
my $thumbnail_dir  = path($Bin, qw(input_files thumbnail ) );
my $error;
my $stderr = do {
    local @ARGV = split(" ", qq(
      create_thumbnails_from_tiff
      --log_config_path $log_config_path
      --tiff $tiff_dir
      --thumbnail $thumbnail_dir  
    ) );
    stderr_from( sub {
        eval { Remedi::Cmd->run; 1 } or $error = $@;
    } );
};

diag $error;
diag "STDERR:" . $stderr;

ok(!$error, 'no errors') or diag $error;
done_testing();
