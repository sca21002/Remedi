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
    rmdir_dirs => [ 'reference' ],
    make_path  => [ 'reference' ],
    copy => [ 
        { 
            glob => 'ubr00003_000[1,2].pdf',
            dir  => 'reference',
        },
        { 
            glob => 'ubr00003_0003.jp2',
            dir  => 'reference',
        },


    ],
});

note("may take some time ..");

my $log_config_path = path($Bin, qw( config log4perl_screen.conf ) );
my $configfile     = path($Bin, qw( config remedi_de-355.conf ) );
my $image_basepath = path($Bin, qw(input_files) );
my $error;
my $stderr = do {
    local @ARGV = split(" ", qq(
      create_thumbnails
      --log_config_path $log_config_path
      --configfile $configfile
      --title 'Titel'
      --image_basepath $image_basepath
      --list 1-3
    ) );
    stderr_from( sub {
        eval { Remedi::Cmd->run; 1 } or $error = $@;
    } );
};

diag $error;
diag "STDERR:" . $stderr;

ok(!$error, 'no errors') or diag $error;
done_testing();
