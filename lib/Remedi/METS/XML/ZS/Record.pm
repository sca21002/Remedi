package Remedi::METS::XML::ZS::Record;

# ABSTRACT: Class for ZS::Record in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'recordData_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::ZS::RecordData]',
     is          => 'ro',     init_arg    => 'recordDatas',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_recordData => ['push'] },     description => {
        LocalName => "recordData",
        Prefix => "zs",
        node_type => "child",
        Name => "zs:recordData",
        NamespaceURI => "http://www.loc.gov/zing/srw/",
        sort_order => 2,
     },
);
has 'recordPacking_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::ZS::RecordPacking]',
     is          => 'ro',     init_arg    => 'recordPackings',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_recordPacking => ['push'] },     description => {
        LocalName => "recordPacking",
        Prefix => "zs",
        node_type => "child",
        Name => "zs:recordPacking",
        NamespaceURI => "http://www.loc.gov/zing/srw/",
        sort_order => 1,
     },
);
has 'recordPosition_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::ZS::RecordPosition]',
     is          => 'ro',     init_arg    => 'recordPositions',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_recordPosition => ['push'] },     description => {
        LocalName => "recordPosition",
        Prefix => "zs",
        node_type => "child",
        Name => "zs:recordPosition",
        NamespaceURI => "http://www.loc.gov/zing/srw/",
        sort_order => 3,
     },
);
has 'recordSchema_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::ZS::RecordSchema]',
     is          => 'ro',     init_arg    => 'recordSchemas',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_recordSchema => ['push'] },     description => {
        LocalName => "recordSchema",
        Prefix => "zs",
        node_type => "child",
        Name => "zs:recordSchema",
        NamespaceURI => "http://www.loc.gov/zing/srw/",
        sort_order => 0,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
