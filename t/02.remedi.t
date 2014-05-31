use utf8;
package ModuleXY;
use Moose;
    with 'Remedi';
    with 'MooseX::SimpleConfig';
    with 'MooseX::Log::Log4perl';

has '_name' => ( is => 'ro', isa => 'Str', default => 'modulexy' ); 

package main;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Test::Fatal;

BEGIN {
    use_ok( 'ModuleXY' ) or exit;
    use_ok( 'Helper' ) or exit;
}

my $remedi1 = ModuleXY->new_with_config(
    configfile =>
        path($Bin)->parent->child( qw( config remedi_de-355.conf ) ),
    library_union_id => 'bvb',
    isil => 'DE-355',
    image_path => '.',
    image_basepath => path($Bin, 'input_files'),
    log_configfile => path($Bin, qw(config log4perl.conf)),
    regex_filestem_var => qr/_\d{1,5}/,
    title => 'My Title',
);

isa_ok($remedi1, 'ModuleXY', '1st instance of ModuleXY'); 


Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    rmdir_dirs => [ qw(archive my_reference ocr) ],
    make_path => [ qw(archive my_reference ocr) ],
    copy => [
        { glob => 'ubr00003_000?.xml',
          dir  => 'ocr',
        },
    ],
});


my $reference_path = path($Bin, 'input_files', 'my_reference'); 
my $remedi2 = ModuleXY->new_with_config(
    reference_path =>  $reference_path,                                   
    configfile =>
        path($Bin)->parent->child( qw( config remedi_de-355.conf ) ),                                  
    library_union_id => 'bvb',
    log_configfile => path($Bin, qw(config log4perl.conf)),
    isil => 'DE-355',
    image_path => '.',
    image_basepath => path($Bin, 'input_files'),
    regex_filestem_var => qr/_\d{1,5}/,
    title => 'My Title',
);

isa_ok($remedi2, 'ModuleXY', '2nd instance of ModuleXY'); 
is($remedi2->_reference_dir, $reference_path, 'reference directory created');
is($remedi2->_ocr_dir->children, 3, 'ocr directory created');
like(
    exception { $remedi2->_archive_dir },
    qr/No files in /, "exception if no image files in working dir"
); 

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    rmdir_dirs => [ qw(archive) ],
    copy => [ 'ubr00003_0001.tif' ],
});

is($remedi2->_archive_dir->children, 1, 'archive_dir has 1 files');
ok( ($remedi2->_archive_dir->children)[0]->remove, 'delete this file');

like(
    exception { $remedi2->archive_files },
    qr/No image files in/, "exception if no image files in archive dir"
);

my $remedi3 = ModuleXY->new(
    isil => 'DE-355',
    ocr_path => 'ocr',
    library_union_id => 'bvb',
    log_configfile => path($Bin, qw(config log4perl.conf)),
    regex_filestem_var => qr/_\d{1,5}/,
    title => 'Mein ÄÖÜ-Titel',
    regex_filestem_prefix => qr/ubr\d{5}/,
    image_basepath => path($Bin, 'input_files'),
);
like(
    exception { $remedi3->creator_pdf_info },
    qr/Attribute 'creator' is not set/,
    "exception if attribute 'creator' is not set",
);

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    rmdir_dirs => [ qw(ingest archive reference ocr thumbnail) ],
    copy => [ 'ubr00003_0001.xml' ],
});


is($remedi3->_ocr_dir->children, 1, 'ocr_dir has 1 files');
ok( ($remedi3->_ocr_dir->children)[0]->remove, 'delete this file');

foreach my $type (qw(ingest_files reference_files thumbnail_files ocr_files)) {
    like(
        exception { $remedi3->$type },
        ($type eq 'ocr_files') ? qr/No ocr files in/ : qr/No Imagefiles in/,
        "exception if no image file in $type",
    );
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    make_path => [ qw(archive) ],
    copy => [ { glob => 'ubr00003_0001.tif', dir => 'archive' } ],
});

path($Bin, 'input_files', 'archive', 'Thumbs.db')->touch;
is(@{$remedi3->archive_files}, 1, '1 archive file found');

done_testing();
