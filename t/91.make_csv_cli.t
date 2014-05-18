use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Test::Output qw(stderr_from);
use File::Compare;

BEGIN {
    use_ok( 'Remedi::Cmd' ) or exit;
    use_ok( 'Helper' ) or exit;
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    copy => ['ubr00003*.tif'],
});

note("may take some time ..");

my $configfile     = path($Bin, qw( config remedi_de-355.conf   ) );
my $log_configfile = path($Bin, qw( config log4perl_screen.conf ) );

my $error;
my $stderr = do {
    local @ARGV = split(" ", qq(
      csv
      --configfile $configfile
      --log_configfile $log_configfile
      --title MyTitle
    ) );
    stderr_from( sub {
        eval { Remedi::Cmd->run; 1 } or $error = $@;
    } );
};

#diag $error;
#diag "STDERR:" . $stderr;

ok(!$error, 'no errors');
like($stderr, qr/----- End: CSV -----/, 'CSV finished');
ok(
    compare(
        path($Bin, qw(input_files ubr00003.csv) ),
        path($Bin, qw(input_files save ubr00003_0003.pdf) )
    ),
    'csv file is as expected'
);

done_testing();