package Remedi::METS::XML::FLocat;

# ABSTRACT: Class for FLocat in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'href' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "href",
        Prefix => "xlink",
        node_type => "attribute",
        Name => "xlink:href",
        NamespaceURI => "http://www.w3.org/1999/xlink",
        sort_order => 0,
     },
);
has 'LOCTYPE' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "LOCTYPE",
        Prefix => "",
        node_type => "attribute",
        Name => "LOCTYPE",
        NamespaceURI => "",
        sort_order => 1,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
