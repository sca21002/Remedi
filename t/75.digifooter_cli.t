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
    copy => [qw(ubr00003*.tif ubr00003.pdf)],
});

note("may take some time ..");

my $configfile     = path($Bin, qw( config remedi_de-355.conf   ) );
my $log_configfile = path($Bin, qw( config log4perl_screen.conf ) );

my $error;
my $stderr = do {
    local @ARGV = split(" ", qq(
      digifooter
      --configfile $configfile
      --dest_format_key PDF
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

ok(!$error, 'no errors') or diag $error;
like($stderr, qr/----- End: DigiFooter -----/, 'CSV finished');

done_testing();
