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
        log_level => 'OFF',
        creator => 'Universitätsbibliothek Regensburg', 
        bv_nr => 'BV111111111',
        library_union_id => 'bvb',
        isil => 'DE-355',
        image_path => '.',
        image_basepath => path($Bin, 'input_files'),
        isil => 'DE-355',
        print_source_holder => 'Universitätsbliothek Regensburg',
        regex_filestem_prefix => qr/ubr\d{5}/,
        regex_filestem_var => qr/_\d{1,5}/,
        title => 'Mein ÄÖÜ-Titel',
);
my $out_xml = $task->make_mets;
is_well_formed_xml($out_xml, 'well formed');

done_testing();
