package Remedi::METS::XML::Fptr;

# ABSTRACT: Class for Fptr in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'FILEID' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "FILEID",
        Prefix => "",
        node_type => "attribute",
        Name => "FILEID",
        NamespaceURI => "",
        sort_order => 0,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
