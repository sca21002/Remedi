use utf8;
use strict;
use warnings;
use FindBin qw($Bin);
use Path::Tiny;
use lib path($Bin)->parent(2)->child('lib')->stringify;
use Test::More;

package TestUri;
use Remedi::Types qw(Uri);
use Moose;
use MooseX::AttributeShortcuts;

has 'uri' => (
    is => 'lazy',
    isa => Uri,
    coerce => 1,
);

sub _build_uri {
my $self = shift;

return 'http://test.de';
#return URI::FromHash::uri_object( {scheme => 'http', host => 'test.de'});

}

package main;
use TestUri;

ok(my $uri = TestUri->new());

ok ($uri->uri, 'http://test.de');


done_testing();