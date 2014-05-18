package Remedi::METS::XML::ZS::Records;

# ABSTRACT: Class for ZS::Records in METS XML

use Moose;
use namespace::autoclean;
use XML::Toolkit;

has 'record_collection' => (
     isa         => 'ArrayRef[Remedi::METS::XML::ZS::Record]',
     is          => 'ro',     init_arg    => 'records',
     traits      => [qw(XML Array)],
     lazy        => 1,
     auto_deref  => 1,
     default     => sub { [] },
     handles    => { add_record => ['push'] },     description => {
        LocalName => "record",
        Prefix => "zs",
        node_type => "child",
        Name => "zs:record",
        NamespaceURI => "http://www.loc.gov/zing/srw/",
        sort_order => 0,
     },
);

__PACKAGE__->meta->make_immutable;

1;

__END__
