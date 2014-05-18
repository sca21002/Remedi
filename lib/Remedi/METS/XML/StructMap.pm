package Remedi::METS::XML::StructMap;

# ABSTRACT: Class for StructMap in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'div_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::Div]',
     is          => 'ro',     init_arg    => 'divs',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_div => ['push'] },     description => {
        LocalName => "div",
        Prefix => "",
        node_type => "child",
        Name => "div",
        NamespaceURI => "http://www.loc.gov/METS/",
        sort_order => 0,
     },
);
has 'ID' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "ID",
        Prefix => "",
        node_type => "attribute",
        Name => "ID",
        NamespaceURI => "",
        sort_order => 1,
     },
);
has 'LABEL' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "LABEL",
        Prefix => "",
        node_type => "attribute",
        Name => "LABEL",
        NamespaceURI => "",
        sort_order => 2,
     },
);
has 'TYPE' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "TYPE",
        Prefix => "",
        node_type => "attribute",
        Name => "TYPE",
        NamespaceURI => "",
        sort_order => 3,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
