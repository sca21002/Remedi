use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use Test::More;
use Test::XML;

use warnings  qw(FATAL utf8);    # fatalize encoding glitches
use open      qw(:std :utf8);    # undeclared streams in UTF-8

BEGIN {
    use_ok( 'LWP::UserAgent' ) or exit;
}

my $url =
    'http://bvbr.bib-bvb.de:5661/bvb01sru?version=1.1&recordSchema=marcxml'
    . '&operation=searchRetrieve&query=marcxml.idn=BV021683363&maximumRecords=1';

my $ua = LWP::UserAgent->new();

my $result;
my $response = $ua->get($url);

SKIP: {
    skip $response->status_line, 1 unless $response->is_success;
    $result = $response->decoded_content;
    like($result, qr#<controlfield tag="001">BV021683363</controlfield>#,
        'xml-record');
    is_well_formed_xml($result, 'well formed');
}
done_testing();
