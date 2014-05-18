package Remedi::METS::XML::Div;

# ABSTRACT: Class for Div in METS XML

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
has 'fptr_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::Fptr]',
     is          => 'ro',     init_arg    => 'fptrs',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_fptr => ['push'] },     description => {
        LocalName => "fptr",
        Prefix => "",
        node_type => "child",
        Name => "fptr",
        NamespaceURI => "http://www.loc.gov/METS/",
        sort_order => 1,
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
        sort_order => 2,
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
        sort_order => 3,
     },
);
has 'ORDER' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "ORDER",
        Prefix => "",
        node_type => "attribute",
        Name => "ORDER",
        NamespaceURI => "",
        sort_order => 4,
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
        sort_order => 5,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
