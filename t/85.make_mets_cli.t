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
        { glob => 'ubr00003_000?.pdf',
          dir  => 'reference',
        },        
        { glob => 'ubr00003_000?.gif',
          dir  => 'thumbnail',
        },
        'ubr00003.csv',
        'ubr00003.xml',
    ],
});

note("may take some time ..");

my $configfile     = path($Bin, qw( config remedi_de-355.conf   ) );
my $log_configfile = path($Bin, qw( config log4perl_screen.conf ) );

$Remedi::VERSION = '0.05';

my $error;
my $stderr = do {
    local @ARGV = split(" ", qq(
      mets
      --bv_nr BV111111111
      --configfile $configfile
      --log_configfile $log_configfile
      --source_format PDF
      --title MyTitle
    ) );
    stderr_from( sub {
        eval { Remedi::Cmd->run; 1 } or $error = $@;
    } );
};

#diag $error;
#diag "STDERR:" . $stderr;

ok(!$error, 'no errors');
like($stderr, qr/----- End: METS -----/, 'METS finished');

done_testing();
