use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Test::XML;
use XML::SemanticDiff;
use Data::Dumper;
use DateTime;
use Data::Printer;

use Image::ExifTool;

use warnings  qw(FATAL utf8);    # fatalize encoding glitches
use open      qw(:std :utf8);    # undeclared streams in UTF-8

use Encode qw(decode);

BEGIN {
    use_ok( 'Remedi::METS::App' ) or exit;
    use_ok( 'Helper' ) or exit;
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    rmdir_dirs => [ qw(archive reference ingest) ],
    # make_path => [ qw(archive reference) ],
    copy => [
        { glob => 'ubr00003_000?.tif',
          dir  => '.', # 'archive',
        },
        { source => 'ubr00003.pdf',
          dest   => 'ubr00003.pdf', # path(qw(reference ubr00003.pdf)),
        },        
        { source => 'ubr00003.csv',
          dest   => 'ubr00003.csv',
        },
    ],
});

$Remedi::VERSION = '0.05';

my $task = Remedi::METS::App->new(
#        log_level => 'TRACE',
        author => 'Krömer, Alexander Helmut Kurt',
        bv_nr => 'BV022193304',
        create_date => DateTime->new(
            year       => 2012,
            month      => 9,
            day        => 20,
            hour       => 8,
            minute     => 34,
            second     => 31,
            time_zone  => 'Europe/Berlin',
        ),
        creator => 'Universitätsbibliothek Regensburg', 
        image_basepath => path($Bin, 'input_files'),
        image_path => '.',
        is_thesis_workflow => 1,
        isil => 'DE-355',
        library_union_id => 'bvb',
        log_config_path => path($Bin, qw(config log4perl.conf)),
        print_source_holder => 'Universitätsbliothek Regensburg',
        regex_filestem_prefix => qr/ubr\d{5}/,
        regex_filestem_var => qr/_\d{1,5}/,
        shelf_number => '9123/YI 6504 K93',
        title => 'Therapeutische Potenz adenoviral-exprimierter, löslicher MHC-'
            . 'Klasse I Antigene in der Organtransplantation im Rattenmodell',
        urn_level => 'object',
        usetypes => [ qw(archive reference) ],
        year_of_digitisation => 2012,
        year_of_publication => '2006',
);

SKIP: {
    my $sru = Remedi::BVB::SRU->new();
    my $uri = $sru->get_uri($task->bv_nr);
    my $response = $sru->user_agent->get($uri);
    
    skip $response->status_line, 2 unless $response->is_success;
    my $out_xml = $task->make_mets;
    is_well_formed_xml($out_xml, 'well formed');

    my $xml_1
        = path($Bin, 'input_files', 'save', 'ubr00003_diss_marc_simple_pagelabel.xml')->slurp;
    #is_xml($xml_1, $out_xml, 'METS XML is as expected');
    
    my $diff = XML::SemanticDiff->new(
         ignorexpath => [q{/mets/fileSec/fileGrp/file}],
    );
    my @results = $diff->compare($xml_1, $out_xml);
    ok((!@results), 'METS XML is as expected'); 
    if (@results) {
        diag Dumper(@results);
        path($Bin, 'input_files','ubr00003.xml')->spew_utf8($out_xml);
    }
}

done_testing();
