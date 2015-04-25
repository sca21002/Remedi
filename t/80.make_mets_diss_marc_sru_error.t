use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::Fatal;
use Test::More;

use warnings  qw(FATAL utf8);    # fatalize encoding glitches
use open      qw(:std :utf8);    # undeclared streams in UTF-8

BEGIN {
    use_ok( 'Remedi::METS::App' ) or exit;
    use_ok( 'Helper' ) or exit;
    use_ok( 'Test::LWP::MockSocket::http' ) or exit;
}

$LWP_Response = <<EOF;
HTTP/1.0 200 OK\r\n\r\n<zs:searchRetrieveResponse xmlns:zs="http://www.loc.gov/zing/srw/">
<zs:version>1.1</zs:version>
<zs:numberOfRecords>1</zs:numberOfRecords>
<zs:diagnostics xmlns="http://www.loc.gov/zing/srw/diagnostic/"><diagnostic>
<uri>info:srw/diagnostic/1/67</uri>
<message>Record not available in this schema</message>
<details>Available syntax: XML</details>
</diagnostic>
</zs:diagnostics>
</zs:searchRetrieveResponse>
EOF


Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    rmdir_dirs => [ qw(archive reference ingest) ],
    copy => [
        { glob => 'ubr00003_000?.tif',
          dir  => '.', # 'archive',
        },
        { source => 'ubr00003_with_pagelabels.pdf',
          dest   => 'ubr00003.pdf', # path(qw(reference ubr00003.pdf)),
        },        
        { source => 'ubr00003_with_pagelabels.csv',
          dest   => 'ubr00003.csv',
        },
    ],
});

$Remedi::VERSION = '0.05';

my $task = Remedi::METS::App->new(
        log_level => 'TRACE',
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

like(
    exception { $task->make_mets },
    qr/SRU Error/, "Exception ok: SRU Error"
);

done_testing();
