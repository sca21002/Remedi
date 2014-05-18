use Test::DescribeMe qw(author);
use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent(2)->child('lib')->stringify;
use Test::More;
use Test::XML;

BEGIN {
    use_ok( 'Remedi::BVB::SRU' ) or exit;
}

#ok ( my $sru = Remedi::BVB::SRU->new(bv_nr => 'BV022193304'), 'new instance');
ok ( my $sru = Remedi::BVB::SRU->new(), 'new instance');
ok (my $marc_xml = $sru->get_marc_xml('BV023292038'), 'fetch MARC-XML');
is_well_formed_xml($marc_xml, 'well formed');
#path($Bin, 'input_files', 'marc.xml')->spew_utf8($marc_xml);
#diag $marc_xml;

done_testing();
