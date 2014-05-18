use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More tests => 17;

BEGIN {
    use_ok( 'Remedi' );
    use_ok( 'Remedi::CSV::App' );
    use_ok( 'Remedi::DigiFooter::App' );
    use_ok( 'Remedi::Document' );
    use_ok( 'Remedi::Imagefile' );
    use_ok( 'Remedi::Imagefile::Archive' );
    use_ok( 'Remedi::ImageMagickCmds' );
    use_ok( 'Remedi::METS::App' );
    use_ok( 'Remedi::PDF::API2' );
    use_ok( 'Remedi::Singlepage' );
    use_ok( 'Remedi::Singlepage::PDF' );
    use_ok( 'Remedi::Singlepage::PDF::FromPDF' );
    use_ok( 'Remedi::Singlepage::PDF::FromTIFF' );
    use_ok( 'Remedi::Singlepage::TIFF' );
    use_ok( 'Remedi::Types' );
    use_ok( 'Remedi::Units' );
    use_ok( 'Remedi::Urn_nbn_de' );
}

#diag( "Testing Remedi $Remedi::VERSION" );
