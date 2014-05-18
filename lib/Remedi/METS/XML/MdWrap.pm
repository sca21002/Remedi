package Remedi::METS::XML::MdWrap;

# ABSTRACT: Class for MdWrap in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'MDTYPE' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "MDTYPE",
        Prefix => "",
        node_type => "attribute",
        Name => "MDTYPE",
        NamespaceURI => "",
        sort_order => 0,
     },
);
has 'OTHERMDTYPE' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "OTHERMDTYPE",
        Prefix => "",
        node_type => "attribute",
        Name => "OTHERMDTYPE",
        NamespaceURI => "",
        sort_order => 1,
     },
);
has 'xmlData_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::XmlData]',
     is          => 'ro',
     init_arg    => 'xmlDatas',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_xmlData => ['push'] },
     description => {
        LocalName => "xmlData",
        Prefix => "",
        node_type => "child",
        Name => "xmlData",
        NamespaceURI => "http://www.loc.gov/METS/",
        sort_order => 2,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
