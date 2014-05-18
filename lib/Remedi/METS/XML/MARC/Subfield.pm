package Remedi::METS::XML::MARC::Subfield;

# ABSTRACT: Class for MARC::Subfield in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'code' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "code",
        Prefix => "",
        node_type => "attribute",
        Name => "code",
        NamespaceURI => "",
        sort_order => 0,
     },
);
has 'text' => (
     isa         => 'Str',
     is          => 'rw',   
     traits      => [ 'XML'],
     description => {
        node_type => "character",
        cdata => "",
        sort_order => 1,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
