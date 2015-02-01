use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Log::Log4perl qw(:easy);
use Data::Dumper;
use Test::More;

BEGIN {
    use_ok( 'Remedi::METS::CSV' ) or exit;
    use_ok( 'Helper' ) or exit;
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    copy => [ qw(ubr00003.csv ubr00003_with_pagelabels.csv) ],
});

my $csv;
$csv = Remedi::METS::CSV->new(
    csv_file => path( $Bin, qw(input_files ubr00003_with_pagelabels.csv) )
);

#diag Dumper([$csv->labels]);
is_deeply([$csv->labels],['i', 'Seite 2', 'Seite 3'], 'labels');

$csv = Remedi::METS::CSV->new(
    csv_file => path( $Bin, qw(input_files ubr00003.csv) )
);
#diag Dumper([$csv->labels]);
is_deeply([$csv->labels],[1,2,3], 'labels');

done_testing();
