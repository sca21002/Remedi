use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Modern::Perl;

use warnings  qw(FATAL utf8);    # fatalize encoding glitches
use open      qw(:std :utf8);    # undeclared streams in UTF-8
use Encode qw(decode);

BEGIN {
    use_ok( 'Remedi::PDF::ExifTool::Info' ) or exit;
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
    copy => [ qw(ubr00003.pdf) ],
});

my $app = Log::Log4perl::Appender::TestBuffer->by_name("my_buffer");

my $pdf_info;

$pdf_info = Remedi::PDF::ExifTool::Info->new({
    file => path( $Bin, qw(input_files ubr00003.pdf) ),                                               
    CreationDate => "D:20080428120000+02'00'",
    author       => 'Autor',
    creator      => 'Digitalisiert von der Universitätsbibliothek Regensburg',
    title        => 'Titel',
    keywords     => "key1; key2",
});

$pdf_info->write_info();

my $exifTool = new Image::ExifTool;
$exifTool->Options(Unknown => 1);
my $info = $exifTool->ImageInfo(
    path( $Bin, qw(input_files ubr00003.pdf))->stringify,
    { Duplicates => 1,  List => 1,},
);

my $result;
foreach my $tag ($exifTool->GetFoundTags('Group0')) {
    my $group = $exifTool->GetGroup($tag, 1);
    my $val = $info->{$tag};
    $result->{$group}{$tag} = decode('UTF-8',$val);
}

is($result->{'XMP-dc'}{Creator}, 'Autor', 'XMP-dc Creator');
is($result->{PDF}{Author}, 'Autor', 'PDF Author');
is($result->{'XMP-xmp'}{CreateDate}, '2013:09:23 15:46:22+02:00',
   'XMP-xmp CreateDate');
is($result->{PDF}{'Creator (1)'},
   'Digitalisiert von der Universitätsbibliothek Regensburg',
   'PDF Creator (1)');

done_testing();