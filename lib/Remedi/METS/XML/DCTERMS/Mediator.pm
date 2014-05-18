package Remedi::METS::XML::DCTERMS::Mediator;

# ABSTRACT: Class for DCTERMS::Mediator in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'text' => (
     isa         => 'Str',
     is          => 'rw',   
     traits      => [ 'XML'],
     description => {
        node_type => "character",
        cdata => "",
        sort_order => 0,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
