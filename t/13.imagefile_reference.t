use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;

BEGIN {
    use_ok( 'Remedi::Imagefile::Reference' ) or exit;
    use_ok( 'Remedi::Units' ) or exit;
    use_ok( 'Helper' ) or exit;
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    copy => [ 'ubr00003_0003.tif' ],
});

my $imagefile = Remedi::Imagefile::Reference->new(
    library_union_id => 'bvb',
    isil => 'DE-355',
    file => path($Bin, qw(input_files ubr00003_0003.tif)),
    regex_filestem_prefix => qr/ubr\d{5}/,
    regex_filestem_var => qr/_\d{1,5}/,
    size_class_border => 150 * pt_pro_mm,
);

is($imagefile->path_abs_str,
   path($Bin, qw(input_files ubr00003_0003.tif) )->absolute->stringify,
   'file'
);
note("image file: ", $imagefile->path_abs_str);
is($imagefile->get_niss, 'ubr00003-0003-', 'imagefile->get_niss');

is($imagefile->md5_checksum, '6cffb6e7c200f09f21f971b6d9157bc7',
   'imagefile->md5_checksum');

done_testing();
