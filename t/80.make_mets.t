use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Test::XML;
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
        'ubr00003.xml',
    ],
});

$Remedi::VERSION = '0.05';

my $task = Remedi::METS::App->new(
        bv_nr => 'BV111111111',
        create_date => DateTime->new(
            year       => 2014,
            month      => 3,
            day        => 9,
            hour       => 12,
            minute     => 00,
            second     => 00,
            time_zone  => 'Europe/Berlin',
        ),    
        creator => 'Universitätsbibliothek Regensburg',
        image_basepath => path($Bin, 'input_files'),
        image_path => '.',
        isil => 'DE-355',
        library_union_id => 'bvb',
        log_config_path => path($Bin, qw(config log4perl.conf)),
        log_level => 'TRACE',
        isil => 'DE-355',
        print_source_holder => 'Staatliche Bibliothek Regensburg',
        regex_filestem_prefix => qr/ubr\d{5}/,
        regex_filestem_var => qr/_\d{1,5}/,
        shelf_number => '00/BO 1345 S313',
        title => 'Mein ÄÖÜ-Titel',
        urn_level => 'no_urn',
        usetypes => [ qw(archive reference thumbnail) ],
);
my $out_xml = $task->make_mets;
is_well_formed_xml($out_xml, 'well formed');
my $app = Log::Log4perl::Appender::TestBuffer->by_name("my_buffer");

my $xml_1 = path($Bin, 'input_files', 'save', 'ubr00003.xml')->slurp;
is_xml($xml_1, $out_xml, 'METS XML is as expected');

#diag $app->buffer;
done_testing();
