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
    use_ok( 'Remedi::ImageMagickCmds' ) or exit;
    use_ok( 'Helper' ) or exit;
    use_ok(' Log::Log4perl' ) or exit;
    my $conf = q {
        log4perl.rootLogger =DEBUG, TestBuffer
        log4perl.appender.TestBuffer = Log::Log4perl::Appender::TestBuffer
        log4perl.appender.TestBuffer.layout = SimpleLayout
        log4perl.appender.TestBuffer.name = my_buffer
        log4perl.appender.TestBuffer.utf8 = 1
    };
    Log::Log4perl->init(\$conf);
}

Helper::prepare_input_files({
    input_dir =>  path($Bin, 'input_files'),
    copy => [ 'ubr00003_0003.tif', 'ubr00003_0003_16.tif'  ],
});

convert_image_in_profile(
    path($Bin, qw(input_files ubr00003_0003.tif))->absolute->stringify,
    path($Bin, qw(input_files sRGB.tif))->absolute->stringify,
    path($Bin)->parent->child(
        qw( color sRGB_Color_Space_Profile.icm )
    )->absolute->stringify,
);

ok(path($Bin, qw(input_files sRGB.tif))->is_file, 'convert_image_in_profile');

Remedi::ImageMagickCmds::convert_to_tiff_g4_with_resample(
    path($Bin, qw(input_files ubr00003_0003.tif)),
    path($Bin, qw(input_files ubr00003_0003_g4.tif)),
    50
);

ok( path($Bin, qw(input_files ubr00003_0003_g4.tif))->is_file,
    'convert_to_tiff_g4_with_resample'
);
   
Remedi::ImageMagickCmds::convert_tiff16_to_tiff8(
    path($Bin, qw(input_files ubr00003_0003_16.tif)),
    path($Bin, qw(input_files ubr00003_0003_8.tif)),
);

ok( path($Bin, qw(input_files ubr00003_0003_g4.tif))->is_file,
    'convert_tiff16_to_tiff8'
);
   
done_testing();