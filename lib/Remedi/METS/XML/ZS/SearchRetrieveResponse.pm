package Remedi::METS::XML::ZS::SearchRetrieveResponse;

# ABSTRACT: Class for ZS::SearchRetrieveResponse in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'numberOfRecords_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::ZS::NumberOfRecords]',
     is          => 'ro',     init_arg    => 'numberOfRecordss',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_numberOfRecords => ['push'] },     description => {
        LocalName => "numberOfRecords",
        Prefix => "zs",
        node_type => "child",
        Name => "zs:numberOfRecords",
        NamespaceURI => "http://www.loc.gov/zing/srw/",
        sort_order => 2,
     },
);
has 'records_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::ZS::Records]',
     is          => 'ro',     init_arg    => 'recordss',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_records => ['push'] },     description => {
        LocalName => "records",
        Prefix => "zs",
        node_type => "child",
        Name => "zs:records",
        NamespaceURI => "http://www.loc.gov/zing/srw/",
        sort_order => 3,
     },
);
has 'version_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::ZS::Version]',
     is          => 'ro',     init_arg    => 'versions',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_version => ['push'] },     description => {
        LocalName => "version",
        Prefix => "zs",
        node_type => "child",
        Name => "zs:version",
        NamespaceURI => "http://www.loc.gov/zing/srw/",
        sort_order => 1,
     },
);
has 'zs' => (
     isa         => 'Str',
     is          => 'ro',   
     traits      => [ 'XML'],
     description => {
        LocalName => "zs",
        Prefix => "xmlns",
        node_type => "attribute",
        Name => "xmlns:zs",
        NamespaceURI => "http://www.w3.org/2000/xmlns/",
        sort_order => 0,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
