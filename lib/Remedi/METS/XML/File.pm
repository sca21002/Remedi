package Remedi::METS::XML::File;

# ABSTRACT: Class for File in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'ADMID' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "ADMID",
        Prefix => "",
        node_type => "attribute",
        Name => "ADMID",
        NamespaceURI => "",
        sort_order => 0,
     },
);
has 'CHECKSUM' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "CHECKSUM",
        Prefix => "",
        node_type => "attribute",
        Name => "CHECKSUM",
        NamespaceURI => "",
        sort_order => 6,
     },
);
has 'CHECKSUMTYPE' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "CHECKSUMTYPE",
        Prefix => "",
        node_type => "attribute",
        Name => "CHECKSUMTYPE",
        NamespaceURI => "",
        sort_order => 7,
     },
);
has 'DMDID' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "DMDID",
        Prefix => "",
        node_type => "attribute",
        Name => "DMDID",
        NamespaceURI => "",
        sort_order => 4,
     },
);
has 'FLocat_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::FLocat]',
     is          => 'ro',     init_arg    => 'FLocats',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_FLocat => ['push'] },     description => {
        LocalName => "FLocat",
        Prefix => "",
        node_type => "child",
        Name => "FLocat",
        NamespaceURI => "http://www.loc.gov/METS/",
        sort_order => 8,
     },
);
has 'GROUPID' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "GROUPID",
        Prefix => "",
        node_type => "attribute",
        Name => "GROUPID",
        NamespaceURI => "",
        sort_order => 2,
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
has 'SEQ' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "SEQ",
        Prefix => "",
        node_type => "attribute",
        Name => "SEQ",
        NamespaceURI => "",
        sort_order => 3,
     },
);
has 'SIZE' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "SIZE",
        Prefix => "",
        node_type => "attribute",
        Name => "SIZE",
        NamespaceURI => "",
        sort_order => 5,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
