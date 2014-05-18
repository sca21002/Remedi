use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;
use Test::XML;
use Test::Fatal;

BEGIN {
    use_ok( 'Remedi::BVB::SRU' ) or exit;
}

ok ( my $sru = Remedi::BVB::SRU->new(), 'new instance');
like (
    my $uri = $sru->get_uri('BV021771940'),
    qr/query=marcxml\.idn%3DBV021771940/,
    'uri'
);

SKIP: {
    my $response = $sru->user_agent->get($uri);
    skip $response->status_line, 2 unless $response->is_success;
    ok (my $marc_xml = $sru->get_marc_xml('BV021771940'), 'fetch MARC-XML');
    is_well_formed_xml($marc_xml, 'well formed');
    path($Bin, 'input_files', 'marc.xml')->spew_utf8($marc_xml);
    like(
        exception { $sru->get_marc_xml('BV021771940_') },
        qr/is not a valid B3KatID/, "Exception ok: invalid B3KatID"
    );
}
done_testing();