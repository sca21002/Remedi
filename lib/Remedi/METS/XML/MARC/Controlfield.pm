package Remedi::METS::XML::MARC::Controlfield;

# ABSTRACT: Class for MARC::Controlfield in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'tag' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "tag",
        Prefix => "",
        node_type => "attribute",
        Name => "tag",
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
