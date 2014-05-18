package Remedi::METS::XML::MARC::Datafield;

# ABSTRACT: Class for MARC::Datafield in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'ind1' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     default     => ' ',
     description => {
        LocalName => "ind1",
        Prefix => "",
        node_type => "attribute",
        Name => "ind1",
        NamespaceURI => "",
        sort_order => 2,
     },
);
has 'ind2' => (
     isa         => 'Str',
     is          => 'ro',   
     default     => ' ',
     traits      => [ 'XML'],
     description => {
        LocalName => "ind2",
        Prefix => "",
        node_type => "attribute",
        Name => "ind2",
        NamespaceURI => "",
        sort_order => 3,
     },
);
has 'subfield_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::MARC::Subfield]',
     is          => 'ro',
     init_arg    => 'subfields',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => {
        add_subfield => ['push'],
        grep_subfields => 'grep',
     },
     description => {
        LocalName => "subfield",
        Prefix => "",
        node_type => "child",
        Name => "subfield",
        NamespaceURI => "http://www.loc.gov/MARC21/slim",
        sort_order => 0,
     },
);
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
        sort_order => 1,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
