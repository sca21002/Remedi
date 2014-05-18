use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;

BEGIN {
    use_ok( 'Remedi::Imagefile' ) or exit;
    use_ok( 'Remedi::Units' ) or exit;
    use_ok( 'Helper' ) or exit;
    use_ok( 'Log::Log4perl', qw(:easy) ) or exit;
    ok(Log::Log4perl->easy_init(), 'init logging' );
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    copy => [ 'ubr00003_0003.jpg' ],
});

my $imagefile = Remedi::Imagefile->new(
    library_union_id => 'bvb',
    isil => 'DE-355',
    file => path($Bin, 'input_files','ubr00003_0003.jpg'),
    regex_filestem_prefix => qr/ubr00003/,
    regex_filestem_var => qr/_\d{1,5}/,
    size_class_border => 150 * pt_pro_mm,
);

is($imagefile->colortype,'color','colortype');
is($imagefile->format, 'JPEG','format');
is($imagefile->height_px, 691,'height_px');
is($imagefile->id, 'ubr00003_0003_jpg_file','id');
is($imagefile->path_abs_str,
    path($Bin, qw(input_files ubr00003_0003.jpg))->absolute->stringify, 'file'
);
is($imagefile->basename, 'ubr00003_0003.jpg','basename');
is($imagefile->size, '368503','size');
my @box = (0,0,413,663);
is_deeply($imagefile->mediabox, \@box,'mediabox');
is($imagefile->order_id, 'ubr00003','order_id');
is($imagefile->resolution, '75','resolution');
is($imagefile->size_class, 'small','size_class');
is($imagefile->width_px, '430','width_px');
is($imagefile->icc_profile, 'OS10000_A2_B5_mG', 'ICC-profile');

done_testing();
