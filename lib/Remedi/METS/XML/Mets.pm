package Remedi::METS::XML::Mets;

# ABSTRACT: Class for Mets in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'amdSec_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::AmdSec]',
     is          => 'ro',
     init_arg    => 'amdSecs',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_amdSec => ['push'] },
     description => {
        LocalName => "amdSec",
        Prefix => "",
        node_type => "child",
        Name => "amdSec",
        NamespaceURI => "http://www.loc.gov/METS/",
        sort_order => 8,
     },
);
has 'dmdSec_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::DmdSec]',
     is          => 'ro',     init_arg    => 'dmdSecs',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_dmdSec => ['push'] },     description => {
        LocalName => "dmdSec",
        Prefix => "",
        node_type => "child",
        Name => "dmdSec",
        NamespaceURI => "http://www.loc.gov/METS/",
        sort_order => 7,
     },
);
has 'fileSec_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::FileSec]',
     is          => 'ro',     init_arg    => 'fileSecs',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_fileSec => ['push'] },     description => {
        LocalName => "fileSec",
        Prefix => "",
        node_type => "child",
        Name => "fileSec",
        NamespaceURI => "http://www.loc.gov/METS/",
        sort_order => 9,
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
        sort_order => 1,
     },
);
has 'metsHdr_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::MetsHdr]',
     is          => 'ro',     init_arg    => 'metsHdrs',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_metsHdr => ['push'] },     description => {
        LocalName => "metsHdr",
        Prefix => "",
        node_type => "child",
        Name => "metsHdr",
        NamespaceURI => "http://www.loc.gov/METS/",
        sort_order => 6,
     },
);
has 'OBJID' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "OBJID",
        Prefix => "",
        node_type => "attribute",
        Name => "OBJID",
        NamespaceURI => "",
        sort_order => 2,
     },
);
has 'schemaLocation' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     default     => 'http://www.loc.gov/METS/ http://www.loc.gov/standards/mets/version16/mets.xsd',
     description => {
        LocalName => "schemaLocation",
        Prefix => "xsi",
        node_type => "attribute",
        Name => "xsi:schemaLocation",
        NamespaceURI => "http://www.w3.org/2001/XMLSchema-instance",
        sort_order => 5,
     },
);
has 'structMap_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::StructMap]',
     is          => 'ro',     init_arg    => 'structMaps',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_structMap => ['push'] },     description => {
        LocalName => "structMap",
        Prefix => "",
        node_type => "child",
        Name => "structMap",
        NamespaceURI => "http://www.loc.gov/METS/",
        sort_order => 9,
     },
);
has 'xlink' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "xlink",
        Prefix => "xmlns",
        node_type => "attribute",
        Name => "xmlns:xlink",
        NamespaceURI => "http://www.w3.org/2000/xmlns/",
        sort_order => 3,
     },
);
has 'xmlns' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "xmlns",
        Prefix => "",
        node_type => "attribute",
        Name => "xmlns",
        NamespaceURI => "",
        sort_order => 0,
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
        sort_order => 4,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
