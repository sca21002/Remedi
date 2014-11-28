use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;

BEGIN {
    use_ok( 'Remedi::BVB::SRU' ) or exit;
    use_ok( 'Test::LWP::MockSocket::http' ) or exit;
}

$LWP_Response = <<EOF;
HTTP/1.0 200 OK\r\n\r\n<zs:searchRetrieveResponse xmlns:zs="http://www.loc.gov/zing/srw/">
<zs:version>1.1</zs:version>
<zs:numberOfRecords>1</zs:numberOfRecords>
<zs:diagnostics xmlns="http://www.loc.gov/zing/srw/diagnostic/"><diagnostic>
<uri>info:srw/diagnostic/1/67</uri>
<message>Record not available in this schema</message>
<details>Available syntax: XML</details>
</diagnostic>
</zs:diagnostics>
</zs:searchRetrieveResponse>
EOF

ok ( my $sru = Remedi::BVB::SRU->new(), 'new instance');
ok (my $marc_xml = $sru->get_marc_xml('BV021771940'), 'fetch MARC-XML');

done_testing();
