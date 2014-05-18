package Remedi::METS::XML::Record;

# ABSTRACT: Class for Record in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'creator_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::DC::Creator]',
     is          => 'ro',     init_arg    => 'creators',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_creator => ['push'] },     description => {
        LocalName => "creator",
        Prefix => "dc",
        node_type => "child",
        Name => "dc:creator",
        NamespaceURI => "http://purl.org/dc/elements/1.1/",
        sort_order => 0,
     },
);
has 'date_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::DC::Date]',
     is          => 'ro',     init_arg    => 'dates',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_date => ['push'] },     description => {
        LocalName => "date",
        Prefix => "dc",
        node_type => "child",
        Name => "dc:date",
        NamespaceURI => "http://purl.org/dc/elements/1.1/",
        sort_order => 1,
     },
);
has 'dc' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "dc",
        Prefix => "xmlns",
        node_type => "attribute",
        Name => "xmlns:dc",
        NamespaceURI => "http://www.w3.org/2000/xmlns/",
        sort_order => 2,
     },
);
has 'dcterms' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "dcterms",
        Prefix => "xmlns",
        node_type => "attribute",
        Name => "xmlns:dcterms",
        NamespaceURI => "http://www.w3.org/2000/xmlns/",
        sort_order => 3,
     },
);
has 'identifier_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::DC::Identifier]',
     is          => 'ro',     init_arg    => 'identifiers',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_identifier => ['push'] },     description => {
        LocalName => "identifier",
        Prefix => "dc",
        node_type => "child",
        Name => "dc:identifier",
        NamespaceURI => "http://purl.org/dc/elements/1.1/",
        sort_order => 4,
     },
);
has 'mediator_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::DCTERMS::Mediator]',
     is          => 'ro',     init_arg    => 'mediators',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_mediator => ['push'] },     description => {
        LocalName => "mediator",
        Prefix => "dcterms",
        node_type => "child",
        Name => "dcterms:mediator",
        NamespaceURI => "http://purl.org/dc/terms/",
        sort_order => 5,
     },
);
has 'publisher_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::DC::Publisher]',
     is          => 'ro',     init_arg    => 'publishers',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_publisher => ['push'] },     description => {
        LocalName => "publisher",
        Prefix => "dc",
        node_type => "child",
        Name => "dc:publisher",
        NamespaceURI => "http://purl.org/dc/elements/1.1/",
        sort_order => 6,
     },
);
has 'source_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::DC::Source]',
     is          => 'ro',     init_arg    => 'sources',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_source => ['push'] },     description => {
        LocalName => "source",
        Prefix => "dc",
        node_type => "child",
        Name => "dc:source",
        NamespaceURI => "http://purl.org/dc/elements/1.1/",
        sort_order => 7,
     },
);
has 'title_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::DC::Title]',
     is          => 'ro',     init_arg    => 'titles',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_title => ['push'] },     description => {
        LocalName => "title",
        Prefix => "dc",
        node_type => "child",
        Name => "dc:title",
        NamespaceURI => "http://purl.org/dc/elements/1.1/",
        sort_order => 8,
     },
);
has 'xsi' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "xsi",
        Prefix => "xmlns",
        node_type => "attribute",
        Name => "xmlns:xsi",
        NamespaceURI => "http://www.w3.org/2000/xmlns/",
        sort_order => 9,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
