package Remedi::METS::XML::Agent;

# ABSTRACT: Class for Agent in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'name_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::Name]',
     is          => 'ro',     init_arg    => 'names',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_name => ['push'] },     description => {
        LocalName => "name",
        Prefix => "",
        node_type => "child",
        Name => "name",
        NamespaceURI => "http://www.loc.gov/METS/",
        sort_order => 0,
     },
);
has 'note_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::Note]',
     is          => 'ro',     init_arg    => 'notes',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_note => ['push'] },     description => {
        LocalName => "note",
        Prefix => "",
        node_type => "child",
        Name => "note",
        NamespaceURI => "http://www.loc.gov/METS/",
        sort_order => 1,
     },
);
has 'OTHERTYPE' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "OTHERTYPE",
        Prefix => "",
        node_type => "attribute",
        Name => "OTHERTYPE",
        NamespaceURI => "",
        sort_order => 2,
     },
);
has 'ROLE' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "ROLE",
        Prefix => "",
        node_type => "attribute",
        Name => "ROLE",
        NamespaceURI => "",
        sort_order => 3,
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
        sort_order => 4,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
