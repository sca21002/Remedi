#use Test::DescribeMe qw(author);
use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent(2)->child('t', 'lib')->stringify,
        path($Bin)->parent(2)->child('lib')->stringify;
use Test::More;
use Data::Printer;
use Modern::Perl;

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

#Helper::prepare_input_files({
   # input_dir =>  path($Bin)->parent(2)->child('t', 'input_files'),
   # copy => [ qw(ubr00003.pdf) ],
#});

my $app = Log::Log4perl::Appender::TestBuffer->by_name("my_buffer");

my $pdf = Remedi::PDF::ExifTool::Info->new({
    file => path( path($Bin)->parent(2), qw(t input_files ubr00003.pdf) ),                                               
    create_date => "D:20080428120000+02'00'",
    author      => 'Autor1, Vorname1; Autor2, Vorname2',
    creator      => 'Digitalisiert von der Universitätsbibliothek Regensburg',
    publisher    => 'Dissertation, Universität Regensburg',
    year_of_publication => '2006',
    shelf_number       => '9123/YI 6504 K93',
    bv_nr   => 'BV022193304',
    title        => 'Titel',
});

$pdf->SetNewValue('PDF:Keywords', 'TEST1');

$pdf->write_info();
diag $app->buffer;

my $exifTool = new Image::ExifTool;

$exifTool->Options(
    Unknown => 1,
    List    => 1,
);
my $info = $exifTool->ImageInfo(
    path( path($Bin)->parent(2), qw(t input_files ubr00003.pdf))->stringify,
);

p $info;

my $group = '';
my $tag;
foreach $tag ($exifTool->GetFoundTags('Group0')) {
    if ($group ne $exifTool->GetGroup($tag, 1)) {
        $group = $exifTool->GetGroup($tag, 1);
        print "---- $group ----\n";
    }
    my $val = $info->{$tag};
    if (ref $val eq 'SCALAR') {
        if ($$val =~ /^Binary data/) {
            $val = "($$val)";
        } else {
            my $len = length($$val);
            $val = "(Binary data $len bytes)";
        }
    }
    printf("%-32s : %s\n", $exifTool->GetDescription($tag), p($val));
}

#my @delGroups = Image::ExifTool::GetDelGroups();
#
#say Dumper('DE: ', \@delGroups); 
#
#$exifTool->SetNewValue('PDF:*');
#$exifTool->WriteInfo(
#    path( $Bin, qw(input_files ubr00003.pdf))->stringify,
#    
#) or die "Couldn't write to pdf";


done_testing();