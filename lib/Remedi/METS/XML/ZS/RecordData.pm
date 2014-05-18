package Remedi::METS::XML::ZS::RecordData;

# ABSTRACT: Class for ZS::RecordData in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'record_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::MARC::Record]',
     is          => 'ro',     init_arg    => 'records',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_record => ['push'] },     description => {
        LocalName => "record",
        Prefix => "",
        node_type => "child",
        Name => "record",
        NamespaceURI => "http://www.loc.gov/MARC21/slim",
        sort_order => 0,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
