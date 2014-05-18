use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Test::Fatal;

BEGIN {
    use_ok( 'Remedi::RemediFile' ) or exit;
    use_ok( 'Helper' ) or exit;
    use_ok( 'Log::Log4perl', qw(:easy) );
    ok(Log::Log4perl->easy_init(), 'init logging' );
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    copy => [ 'ubr00003_0003.tif', 'ubr00003.pdf' ],
});

my $file = Remedi::RemediFile->new(
    library_union_id => 'bvb',
    isil => 'DE-355',
    file => path($Bin, qw(input_files ubr00003_0003.tif) ),
    regex_filestem_prefix => qr/ubr\d{5}/,
    regex_filestem_var => qr/_\d{1,5}/,
);

is($file->basename, 'ubr00003_0003.tif', 'basename');
is($file->filestem, 'ubr00003_0003', 'filestem');
is($file->id      , 'ubr00003_0003_tif_file', 'id');
is($file->md5_checksum, '6cffb6e7c200f09f21f971b6d9157bc7', 'MD5');
is($file->order_id, 'ubr00003', 'order_id');
is($file->path_abs_str,
   path($Bin, qw(input_files ubr00003_0003.tif))->absolute->stringify, 'file'
);
is($file->size, 973892, 'size');
is($file->index, 3, 'index');
like($file->stringify, qr#input_files.ubr00003_0003.tif#, 'stringify');

like(
    exception {
        my $file_not_existing = Remedi::RemediFile->new(
            library_union_id => 'bvb',
            isil => 'DE-355',
            file => path($Bin, qw(input_files ubr00003_0005.tif) ),
            regex_filestem_prefix => qr/ubr\d{5}/,
            regex_filestem_var => qr/_\d{1,5}/,            
        );
    }, qr/ubr00003_0005.tif.*does not exist/, "exception if file doesn't exist"
); 

$file = Remedi::RemediFile->new(
    library_union_id => 'bvb',
    isil => 'DE-355',
    file => path($Bin, qw(input_files ubr00003.pdf) ),
    regex_filestem_prefix => qr/ubr\d{5}/,
    regex_filestem_var => qr/_\d{1,5}/,
);

is($file->index, 0, 'index');


done_testing();
