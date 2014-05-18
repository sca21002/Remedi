use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Test::XML;
# use Devel::Leak::Object qw{ GLOBAL_bless };
# $Devel::Leak::Object::TRACKSOURCELINES = 1;
use Data::Dumper;
        
BEGIN {
    use_ok( 'Remedi::METS::App' ) or exit;
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
    ],
});

$Remedi::VERSION = '0.05';

my $task = Remedi::METS::App->new_with_config(
    configfile => path($Bin, qw(config remedi_de-355.conf)),
    title => 'Mein ÄÖÜ-Titel',
    bv_nr => 'BV111111111',
    shelf_number => '00/BO 1345 S313',
    image_basepath => path($Bin, 'input_files'),
    create_date => DateTime->new(
        year       => 2014,
        month      => 3,
        day        => 9,
        hour       => 12,
        minute     => 00,
        second     => 00,
        time_zone  => 'Europe/Berlin',
    ),    
); 

my $out_xml = $task->make_mets;
is_well_formed_xml($out_xml, 'well formed');
my $app = Log::Log4perl::Appender::TestBuffer->by_name("my_buffer");

my $xml_1 = path($Bin, 'input_files', 'save', 'ubr00003_with_config.xml')->slurp;
is_xml($xml_1, $out_xml, 'METS XML is as expected');

#diag $app->buffer;
done_testing();
