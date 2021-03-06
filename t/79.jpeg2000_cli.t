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
    rmdir_dirs => [ qw(archive reference thumbnail ingest) ],
    make_path => [ qw(archive reference thumbnail) ],
    copy => [
        { glob => 'ubr00003_000?.tif',
          dir  => 'archive',
        },
        { glob => 'ubr00003_000[13].pdf',
          dir  => 'reference',
        },        
        { glob => 'ubr00003_000?.gif',
          dir  => 'thumbnail',
        },
        { glob => 'ubr00003_0002.tif',
          dir  => 'reference',
        },
    ],
});

note("may take some time ..");

my $configfile     = path($Bin, qw( config remedi_de-355.conf   ) );
my $log_config_path = path($Bin, qw( config log4perl_screen.conf ) );

my $error;
my $stderr = do {
    local @ARGV = split(" ", qq(
      jpeg2000  
      --configfile $configfile
      --log_config_path $log_config_path
      --title MyTitle
  ) );
    stderr_from( sub {
        eval { Remedi::Cmd->run; 1 } or $error = $@;
    } );
};

#diag $error;
#diag "STDERR:" . $stderr;

#ok(!$error, 'no errors') or diag $error;
#like($stderr, qr/----- End: DigiFooter -----/, 'CSV finished');

done_testing();
