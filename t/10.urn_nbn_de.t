use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->child('lib')->stringify,
        path($Bin)->parent->child('lib')->stringify;
use Test::More;

package Test_Urn_nbn_de;
use Moose;
    with 'Remedi::Urn_nbn_de';

sub get_niss { 'ubr01717-002-' }

package main;

my @urn_tests = (
    {   library_union_id => 'bvb',
        isil => 'DE-355',
        niss => 'ubr01717-002-',
        result => 'urn:nbn:de:bvb:355-ubr01717-002-7',
    },
    {   library_union_id => 'bvb',
        isil => 'DE-384',
        niss => 'uba000264-0001-',
        result => 'urn:nbn:de:bvb:384-uba000264-0001-3',
    },    
);

foreach my $urn_test (@urn_tests) {
    my $urn_obj = Test_Urn_nbn_de->new(
        library_union_id => $urn_test->{library_union_id},
        isil       => $urn_test->{isil},
        $urn_test->{isil} ne 'DE-355' ? (niss => $urn_test->{niss}) : (),
    );   
    isa_ok( $urn_obj, 'Test_Urn_nbn_de');

    is( $urn_obj->urn, $urn_test->{result},
       'urn method should return urn with checksum as a string '
    );
}

done_testing();