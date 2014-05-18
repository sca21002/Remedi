use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
use File::Compare;
use Data::Dumper;

BEGIN {
    use_ok( 'Remedi::CSV::App' ) or exit;
    use_ok( 'Helper' ) or exit;
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    copy => ['ubr00003*.tif'],
});

my $task = Remedi::CSV::App->new(
    isil => 'DE-355',
    library_union_id => 'bvb',
    log_configfile => path($Bin, qw(config log4perl.conf)),
    image_basepath => path($Bin, 'input_files'),
    image_path => '.',
    regex_filestem_prefix => qr/ubr\d{5}/,
    regex_filestem_var => qr/_\d{1,5}/,
    title => 'My Title',
); 
$task->make_csv;

my $app = Log::Log4perl::Appender::TestBuffer->by_name("my_buffer");
like($app->buffer, qr/----- End: CSV -----/, 'CSV finished');
#diag $app->buffer;

ok(
    compare(
        path($Bin, qw(input_files ubr00003.csv) ),
        path($Bin, qw(input_files save ubr00003.csv) )
    ),
    'csv file is as expected'
);

done_testing();
